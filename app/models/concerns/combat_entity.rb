# frozen_string_literal: true

# CombatEntity concern provides unified combat behavior for NPCs and Monsters
# Supports D&D 5e combat mechanics including ability checks, saving throws, damage, and healing
#
# Models including this concern must have:
# - strength, dexterity, constitution, intelligence, wisdom, charisma (integer)
# - armor_class (integer)
# - hit_points, max_hit_points (integer)
# - initiative (integer, optional)
# - conditions (text, optional)
module CombatEntity
  extend ActiveSupport::Concern

  # D&D 5e Ability Score Modifiers
  # Standard formula: (ability_score - 10) / 2, rounded down

  def strength_modifier
    calculate_modifier(strength)
  end

  def dexterity_modifier
    calculate_modifier(dexterity)
  end

  def constitution_modifier
    calculate_modifier(constitution)
  end

  def intelligence_modifier
    calculate_modifier(intelligence)
  end

  def wisdom_modifier
    calculate_modifier(wisdom)
  end

  def charisma_modifier
    calculate_modifier(charisma)
  end

  # Combat Methods

  def take_damage(amount, damage_type: nil)
    return if amount <= 0

    # Apply damage resistances/immunities if present
    modified_amount = apply_damage_modifiers(amount, damage_type)

    self.hit_points = [hit_points - modified_amount, 0].max
    save

    {
      damage_dealt: modified_amount,
      remaining_hp: hit_points,
      defeated: defeated?
    }
  end

  def heal(amount)
    return if amount <= 0 || hit_points >= max_hit_points

    self.hit_points = [hit_points + amount, max_hit_points].min
    save

    {
      healing_done: amount,
      current_hp: hit_points,
      max_hp: max_hit_points
    }
  end

  def defeated?
    hit_points <= 0
  end

  def alive?
    !defeated?
  end

  def roll_initiative
    self.initiative = DiceRoller.roll('1d20') + dexterity_modifier
    save
    initiative
  end

  def make_saving_throw(ability_name, dc)
    modifier = send("#{ability_name}_modifier")

    # Check if proficient in this save (from JSONB saving_throws field)
    proficient_saves = respond_to?(:saving_throws) ? (saving_throws || {}) : {}
    is_proficient = proficient_saves.key?(ability_name.to_s) || proficient_saves.key?(ability_name.to_sym)

    # Add proficiency bonus if proficient
    proficiency = respond_to?(:proficiency_bonus) ? (proficiency_bonus || 0) : 0
    total_modifier = modifier + (is_proficient ? proficiency : 0)

    roll = DiceRoller.roll('1d20')
    total = roll + total_modifier
    success = total >= dc

    {
      success: success,
      roll: roll,
      modifier: total_modifier,
      total: total,
      dc: dc,
      ability: ability_name,
      natural_20: roll == 20,
      natural_1: roll == 1
    }
  end

  def make_attack_roll(target_ac)
    # Default to STR modifier for melee, could be overridden
    attack_modifier = strength_modifier
    proficiency = respond_to?(:proficiency_bonus) ? (proficiency_bonus || 0) : 0
    attack_bonus = attack_modifier + proficiency

    roll = DiceRoller.roll('1d20')
    total = roll + attack_bonus

    hit = total >= target_ac
    critical = roll == 20
    critical_miss = roll == 1

    {
      hit: hit || critical,
      critical: critical,
      critical_miss: critical_miss,
      roll: roll,
      bonus: attack_bonus,
      total: total,
      target_ac: target_ac
    }
  end

  def make_skill_check(skill_name, dc)
    # Map skills to abilities
    ability_map = {
      'athletics' => :strength,
      'acrobatics' => :dexterity,
      'sleight_of_hand' => :dexterity,
      'stealth' => :dexterity,
      'arcana' => :intelligence,
      'history' => :intelligence,
      'investigation' => :intelligence,
      'nature' => :intelligence,
      'religion' => :intelligence,
      'animal_handling' => :wisdom,
      'insight' => :wisdom,
      'medicine' => :wisdom,
      'perception' => :wisdom,
      'survival' => :wisdom,
      'deception' => :charisma,
      'intimidation' => :charisma,
      'performance' => :charisma,
      'persuasion' => :charisma
    }

    ability = ability_map[skill_name.to_s]
    return { error: "Unknown skill: #{skill_name}" } unless ability

    ability_modifier = send("#{ability}_modifier")

    # Check skill proficiency from JSONB skills field
    skill_proficiencies = respond_to?(:skills) ? (skills || {}) : {}
    is_proficient = skill_proficiencies.key?(skill_name.to_s) || skill_proficiencies.key?(skill_name.to_sym)

    proficiency = respond_to?(:proficiency_bonus) ? (proficiency_bonus || 0) : 0
    total_modifier = ability_modifier + (is_proficient ? proficiency : 0)

    roll = DiceRoller.roll('1d20')
    total = roll + total_modifier
    success = total >= dc

    {
      success: success,
      roll: roll,
      modifier: total_modifier,
      total: total,
      dc: dc,
      skill: skill_name,
      ability: ability,
      natural_20: roll == 20,
      natural_1: roll == 1
    }
  end

  def add_condition(condition_name)
    return if has_condition?(condition_name)

    current_conditions = (conditions || '').split(',').map(&:strip)
    current_conditions << condition_name
    self.conditions = current_conditions.join(', ')
    save
  end

  def remove_condition(condition_name)
    return unless has_condition?(condition_name)

    current_conditions = (conditions || '').split(',').map(&:strip)
    current_conditions.delete(condition_name)
    self.conditions = current_conditions.join(', ')
    save
  end

  def has_condition?(condition_name)
    return false if conditions.blank?
    conditions.split(',').map(&:strip).include?(condition_name.to_s)
  end

  def current_conditions
    return [] if conditions.blank?
    conditions.split(',').map(&:strip)
  end

  # Armor Class calculation - can be overridden by models
  def calculated_armor_class
    armor_class || (10 + dexterity_modifier)
  end

  private

  def calculate_modifier(score)
    return 0 if score.nil?
    ((score - 10) / 2).floor
  end

  def apply_damage_modifiers(amount, damage_type)
    return amount if damage_type.nil?

    # Check immunities
    if respond_to?(:damage_immunities) && damage_immunities.present?
      immunities = damage_immunities.split(',').map(&:strip)
      return 0 if immunities.include?(damage_type.to_s)
    end

    # Check resistances (half damage)
    if respond_to?(:damage_resistances) && damage_resistances.present?
      resistances = damage_resistances.split(',').map(&:strip)
      return (amount / 2.0).floor if resistances.include?(damage_type.to_s)
    end

    amount
  end
end
