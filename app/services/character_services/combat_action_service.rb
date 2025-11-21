# frozen_string_literal: true

module CharacterServices
  # Service for handling combat actions for D&D 5e characters
  # Includes attacks, spells, damage, and combat mechanics
  # Ported from heretical-web-app with adaptations for terminal-dnd
  class CombatActionService
    attr_reader :character, :tracker

    def initialize(character)
      @character = character
      @tracker = character.character_combat_tracker ||
                 character.create_character_combat_tracker!(
                   action_resources: {},
                   exhaustion_level: 0,
                   temp_hp: 0
                 )
    end

    # ========================================
    # ATTACK ACTIONS
    # ========================================

    # Perform a weapon attack
    def perform_attack(weapon:, target_ac: nil, advantage: false, disadvantage: false, bonus_to_hit: 0,
                       bonus_damage: 0, use_great_weapon_master: false)
      return { success: false, error: 'No action available' } unless action_available?

      # Great Weapon Master: -5 to hit, +10 damage
      if use_great_weapon_master && has_feat?('great_weapon_master')
        bonus_to_hit -= 5
        bonus_damage += 10
      end

      # Calculate attack bonus
      attack_mod = calculate_attack_modifier(weapon)
      total_attack_mod = attack_mod + bonus_to_hit

      # Roll attack
      attack_result = roll_d20(advantage: advantage, disadvantage: disadvantage)
      attack_roll = attack_result[:roll]
      natural_roll = attack_result[:natural]

      # Calculate total
      total = attack_roll + total_attack_mod

      # Check for critical hit or miss
      is_critical = natural_roll == 20
      is_miss = natural_roll == 1

      # Determine if hit
      hit = if is_miss
              false
            elsif is_critical
              true
            elsif target_ac
              total >= target_ac
            else
              nil # Unknown if we don't have target AC
            end

      result = {
        success: true,
        attack_roll: attack_roll,
        natural_roll: natural_roll,
        modifier: total_attack_mod,
        total: total,
        critical: is_critical,
        critical_miss: is_miss,
        hit: hit,
        advantage: advantage,
        disadvantage: disadvantage,
        rolls: attack_result[:rolls],
        great_weapon_master: use_great_weapon_master
      }

      # Roll damage if hit
      if hit
        damage_result = roll_damage(weapon, critical: is_critical, bonus_damage: bonus_damage)
        result[:damage] = damage_result
      end

      # Use action
      use_action

      # Log the attack
      log_action('attack', result.merge(weapon: weapon[:name]))

      result
    end

    # Roll damage for a weapon
    def roll_damage(weapon, critical: false, bonus_damage: 0)
      damage_dice = weapon[:damage_dice] || '1d6'
      damage_type = weapon[:damage_type] || 'slashing'

      # Parse damage dice (e.g., "1d8", "2d6")
      num_dice, die_size = parse_dice(damage_dice)

      # Roll damage
      rolls = num_dice.times.map { rand(1..die_size) }
      base_damage = rolls.sum

      # Double dice on critical (not modifiers)
      if critical
        crit_rolls = num_dice.times.map { rand(1..die_size) }
        base_damage += crit_rolls.sum
        rolls += crit_rolls
      end

      # Add modifiers
      damage_mod = calculate_damage_modifier(weapon)
      total_damage = base_damage + damage_mod + bonus_damage

      {
        rolls: rolls,
        base: base_damage,
        modifier: damage_mod + bonus_damage,
        total: total_damage,
        type: damage_type,
        critical: critical
      }
    end

    # ========================================
    # SPELL CASTING
    # ========================================

    # Cast a spell
    def cast_spell(spell:, target_ac: nil, advantage: false, disadvantage: false, spell_level: nil)
      casting_time = spell[:casting_time] || '1 action'
      spell_level ||= spell[:level] || 1

      # Check if spell slot is available (skip for cantrips)
      if spell_level > 0
        unless has_spell_slot?(spell_level)
          return { success: false, error: "No spell slot available for level #{spell_level}" }
        end
      end

      # Determine what action type is needed
      action_needed = case casting_time.downcase
                      when /bonus action/
                        :bonus_action
                      when /reaction/
                        :reaction
                      else
                        :action
                      end

      # Check if action is available
      case action_needed
      when :action
        return { success: false, error: 'No action available' } unless action_available?
      when :bonus_action
        return { success: false, error: 'No bonus action available' } unless has_bonus_action?
      when :reaction
        return { success: false, error: 'No reaction available' } unless has_reaction?
      end

      result = {
        success: true,
        spell: spell[:name],
        action_type: action_needed,
        spell_level: spell_level
      }

      # Handle spell attack rolls
      if spell[:attack_type] == 'ranged_spell_attack' || spell[:attack_type] == 'melee_spell_attack'
        attack_result = spell_attack(spell, target_ac: target_ac, advantage: advantage, disadvantage: disadvantage)
        result.merge!(attack_result)
      end

      # Handle saving throws
      if spell[:save_dc]
        result[:save_dc] = calculate_spell_save_dc
        result[:save_ability] = spell[:save_ability]
      end

      # Handle special spell effects
      handle_spell_effects(spell, result)

      # Consume spell slot (skip for cantrips)
      consume_spell_slot(spell_level) if spell_level > 0

      # Use the appropriate action
      case action_needed
      when :action
        use_action
      when :bonus_action
        use_bonus_action
      when :reaction
        use_reaction
      end

      # Log the spell
      log_action('spell_cast', result)

      result
    end

    # Cast Shield spell as a reaction
    def cast_shield_reaction(incoming_attack_total:)
      unless has_reaction?
        return { success: false, error: 'No reaction available' }
      end

      unless has_spell_slot?(1)
        return { success: false, error: 'No 1st level spell slot available' }
      end

      # Apply Shield spell: +5 AC until start of next turn
      ac_bonus = 5
      original_ac = character.calculated_armor_class
      new_ac = original_ac + ac_bonus

      # Check if Shield causes the attack to miss
      attack_now_misses = incoming_attack_total < new_ac

      # Consume resources
      consume_spell_slot(1)
      use_reaction

      result = {
        success: true,
        spell: 'Shield',
        original_ac: original_ac,
        new_ac: new_ac,
        ac_bonus: ac_bonus,
        incoming_attack: incoming_attack_total,
        attack_now_misses: attack_now_misses,
        duration: 'until start of next turn'
      }

      # Log the reaction
      log_action('spell_cast_reaction', result)

      result
    end

    # Handle special spell effects
    def handle_spell_effects(spell, result)
      case spell[:name]&.downcase
      when 'shield'
        # Shield grants +5 AC until start of next turn
        result[:ac_bonus] = 5
        result[:duration] = 'until start of next turn'
      when 'cure wounds', 'healing word'
        # Healing spells
        if spell[:healing_dice]
          healing = roll_healing(spell[:healing_dice])
          result[:healing] = healing
        end
      when 'fire bolt', 'ray of frost', 'eldritch blast'
        # Cantrips with damage
        if result[:hit] && spell[:damage_dice]
          damage = roll_spell_damage(spell[:damage_dice], critical: result[:critical])
          result[:damage] = damage
        end
      end
    end

    # Roll spell damage
    def roll_spell_damage(damage_dice, critical: false)
      num_dice, die_size = parse_dice(damage_dice)

      rolls = num_dice.times.map { rand(1..die_size) }
      total = rolls.sum

      if critical
        crit_rolls = num_dice.times.map { rand(1..die_size) }
        total += crit_rolls.sum
        rolls += crit_rolls
      end

      {
        rolls: rolls,
        total: total,
        critical: critical
      }
    end

    # Roll healing
    def roll_healing(healing_dice)
      num_dice, die_size = parse_dice(healing_dice)
      spellcasting_ability = character.character_class&.spellcasting_ability || :wisdom
      ability_mod = character.send("#{spellcasting_ability}_modifier")

      rolls = num_dice.times.map { rand(1..die_size) }
      base = rolls.sum
      total = base + ability_mod

      {
        rolls: rolls,
        base: base,
        modifier: ability_mod,
        total: total
      }
    end

    # Spell attack roll
    def spell_attack(spell, target_ac: nil, advantage: false, disadvantage: false)
      spell_attack_bonus = calculate_spell_attack_bonus

      # Roll attack
      attack_result = roll_d20(advantage: advantage, disadvantage: disadvantage)
      attack_roll = attack_result[:roll]
      natural_roll = attack_result[:natural]

      total = attack_roll + spell_attack_bonus

      # Check for critical
      is_critical = natural_roll == 20
      is_miss = natural_roll == 1

      # Determine if hit
      hit = if is_miss
              false
            elsif is_critical
              true
            elsif target_ac
              total >= target_ac
            else
              nil
            end

      {
        attack_roll: attack_roll,
        natural_roll: natural_roll,
        modifier: spell_attack_bonus,
        total: total,
        critical: is_critical,
        critical_miss: is_miss,
        hit: hit,
        rolls: attack_result[:rolls]
      }
    end

    # ========================================
    # SAVING THROWS
    # ========================================

    # Make a saving throw
    def saving_throw(ability:, dc:, advantage: false, disadvantage: false)
      # Get base ability modifier
      ability_mod = character.send("#{ability}_modifier")

      # Check if proficient in this saving throw
      proficient = proficient_saving_throw?(ability)
      save_bonus = proficient ? ability_mod + proficiency_value : ability_mod

      # Roll
      result = roll_d20(advantage: advantage, disadvantage: disadvantage)
      total = result[:roll] + save_bonus

      success = total >= dc

      save_result = {
        ability: ability,
        roll: result[:roll],
        natural_roll: result[:natural],
        modifier: ability_mod,
        total: total,
        dc: dc,
        success: success,
        advantage: advantage,
        disadvantage: disadvantage,
        rolls: result[:rolls]
      }

      log_action('saving_throw', save_result)

      save_result
    end

    # ========================================
    # CONCENTRATION CHECKS
    # ========================================

    # Check concentration when taking damage
    def concentration_check(damage_taken)
      # DC is 10 or half the damage taken, whichever is higher
      dc = [10, (damage_taken / 2.0).floor].max

      result = saving_throw(ability: :constitution, dc: dc)

      log_action('concentration_check', {
                   damage: damage_taken,
                   dc: dc,
                   result: result[:success] ? 'maintained' : 'lost'
                 })

      result
    end

    # ========================================
    # DAMAGE APPLICATION
    # ========================================

    # Apply damage to character
    def take_damage(amount, damage_type: 'untyped', source: nil, target_hp: nil)
      # Check resistances, immunities, vulnerabilities from tracker
      resources = tracker.action_resources || {}
      resistances = resources['resistances'] || []
      immunities = resources['immunities'] || []
      vulnerabilities = resources['vulnerabilities'] || []

      actual_damage = amount
      damage_modifier = nil

      # Check immunity
      if immunities.include?(damage_type)
        actual_damage = 0
        damage_modifier = 'immune'
      elsif resistances.include?(damage_type)
        actual_damage = (amount / 2.0).floor # D&D 5e rounds down for resistance
        damage_modifier = 'resisted'
      elsif vulnerabilities.include?(damage_type)
        actual_damage = amount * 2
        damage_modifier = 'vulnerable'
      end

      # Calculate overkill if target HP provided (for tracking damage to enemies)
      overkill = nil
      if target_hp && target_hp.positive?
        overkill = actual_damage - target_hp if actual_damage > target_hp
      end

      # Apply to temp HP first
      temp_hp = tracker.temp_hp || 0
      if temp_hp.positive?
        if actual_damage <= temp_hp
          tracker.update(temp_hp: temp_hp - actual_damage)
          actual_damage = 0
        else
          actual_damage -= temp_hp
          tracker.update(temp_hp: 0)
        end
      end

      # Apply remaining damage to HP
      if actual_damage.positive?
        new_hp = [character.hit_points_current - actual_damage, 0].max
        character.update(hit_points_current: new_hp)

        # Check for instant death (massive damage)
        if new_hp.zero? && actual_damage >= character.hit_points_max
          log_action('instant_death', { damage: actual_damage, max_hp: character.hit_points_max })
        end

        # Reset death saves if healed above 0
        reset_death_saves if new_hp.positive?
      end

      result = {
        damage_taken: amount,
        damage_type: damage_type,
        actual_damage: actual_damage,
        resisted: resistances.include?(damage_type),
        immune: immunities.include?(damage_type),
        vulnerable: vulnerabilities.include?(damage_type),
        damage_modifier: damage_modifier,
        overkill: overkill,
        source: source,
        current_hp: character.hit_points_current
      }

      log_action('damage_taken', result)

      result
    end

    # Heal character
    def heal(amount, source: nil)
      current_hp = character.hit_points_current
      max_hp = character.hit_points_max
      new_hp = [current_hp + amount, max_hp].min
      actual_healing = new_hp - current_hp

      character.update(hit_points_current: new_hp)

      # Reset death saves if healed above 0
      reset_death_saves if current_hp.zero? && new_hp.positive?

      result = {
        healing: amount,
        actual_healing: actual_healing,
        source: source,
        current_hp: new_hp
      }

      log_action('healed', result)

      result
    end

    # Add temporary hit points
    def add_temp_hp(amount, source: nil)
      # Temp HP doesn't stack, take the higher value
      current_temp = tracker.temp_hp || 0
      new_temp = [current_temp, amount].max

      tracker.update(temp_hp: new_temp)

      log_action('temp_hp_gained', {
                   amount: amount,
                   previous: current_temp,
                   new: new_temp,
                   source: source
                 })

      { temp_hp: new_temp }
    end

    # ========================================
    # HELPER METHODS
    # ========================================

    private

    # Roll d20 with advantage/disadvantage
    def roll_d20(advantage: false, disadvantage: false)
      if advantage && disadvantage
        # They cancel out
        roll = rand(1..20)
        { roll: roll, natural: roll, rolls: [roll] }
      elsif advantage
        roll1 = rand(1..20)
        roll2 = rand(1..20)
        roll = [roll1, roll2].max
        { roll: roll, natural: roll, rolls: [roll1, roll2] }
      elsif disadvantage
        roll1 = rand(1..20)
        roll2 = rand(1..20)
        roll = [roll1, roll2].min
        { roll: roll, natural: roll, rolls: [roll1, roll2] }
      else
        roll = rand(1..20)
        { roll: roll, natural: roll, rolls: [roll] }
      end
    end

    # Parse dice notation (e.g., "2d6" -> [2, 6])
    def parse_dice(dice_string)
      match = dice_string.match(/(\d+)d(\d+)/)
      return [1, 6] unless match

      [match[1].to_i, match[2].to_i]
    end

    # Calculate attack modifier
    def calculate_attack_modifier(weapon)
      return 0 if weapon.nil?

      ability = weapon[:ability] || :strength
      ability_mod = character.send("#{ability}_modifier")
      proficiency = weapon[:proficient] ? proficiency_value : 0

      ability_mod + proficiency + (weapon[:magic_bonus] || 0)
    end

    # Calculate damage modifier
    def calculate_damage_modifier(weapon)
      return 0 if weapon.nil?

      ability = weapon[:ability] || :strength
      character.send("#{ability}_modifier") + (weapon[:magic_bonus] || 0)
    end

    # Calculate spell attack bonus
    def calculate_spell_attack_bonus
      spellcasting_ability = character.character_class&.spellcasting_ability || :intelligence
      ability_mod = character.send("#{spellcasting_ability}_modifier")
      proficiency = proficiency_value

      ability_mod + proficiency
    end

    # Calculate spell save DC
    def calculate_spell_save_dc
      8 + calculate_spell_attack_bonus
    end

    # Get proficiency bonus based on level
    def proficiency_value
      level = character.level || 1
      case level
      when 1..4
        2
      when 5..8
        3
      when 9..12
        4
      when 13..16
        5
      when 17..20
        6
      else
        2
      end
    end

    # Check if proficient in saving throw
    def proficient_saving_throw?(ability)
      # Get proficient saves from character class
      return false unless character.character_class

      proficient_saves = character.character_class.proficient_saving_throws || []
      proficient_saves.include?(ability.to_s)
    end

    # Check if character has a feat
    def has_feat?(feat_name)
      character.feats.any? { |feat| feat.name.downcase == feat_name.downcase }
    end

    # Check if action is available
    def action_available?
      resources = tracker.action_resources || {}
      current_turn_actions = resources['current_turn_actions'] || {}
      !current_turn_actions['action_used']
    end

    # Check if bonus action is available
    def has_bonus_action?
      resources = tracker.action_resources || {}
      current_turn_actions = resources['current_turn_actions'] || {}
      !current_turn_actions['bonus_action_used']
    end

    # Check if reaction is available
    def has_reaction?
      resources = tracker.action_resources || {}
      current_turn_actions = resources['current_turn_actions'] || {}
      !current_turn_actions['reaction_used']
    end

    # Use action
    def use_action
      resources = tracker.action_resources || {}
      current_turn_actions = resources['current_turn_actions'] || {}
      current_turn_actions['action_used'] = true
      resources['current_turn_actions'] = current_turn_actions

      tracker.action_resources_will_change!
      tracker.action_resources = resources
      tracker.save!
    end

    # Use bonus action
    def use_bonus_action
      resources = tracker.action_resources || {}
      current_turn_actions = resources['current_turn_actions'] || {}
      current_turn_actions['bonus_action_used'] = true
      resources['current_turn_actions'] = current_turn_actions

      tracker.action_resources_will_change!
      tracker.action_resources = resources
      tracker.save!
    end

    # Use reaction
    def use_reaction
      resources = tracker.action_resources || {}
      current_turn_actions = resources['current_turn_actions'] || {}
      current_turn_actions['reaction_used'] = true
      resources['current_turn_actions'] = current_turn_actions

      tracker.action_resources_will_change!
      tracker.action_resources = resources
      tracker.save!
    end

    # Check if spell slot is available
    def has_spell_slot?(spell_level)
      return false if spell_level <= 0 # Cantrips don't use slots

      resources = tracker.action_resources || {}
      spell_slots_total = resources['spell_slots_total'] || {}
      spell_slots_used = resources['spell_slots_used'] || {}

      level_key = spell_level_key(spell_level)
      total = spell_slots_total[level_key] || 0
      used = spell_slots_used[level_key] || 0

      used < total
    end

    # Consume spell slot
    def consume_spell_slot(spell_level)
      return if spell_level <= 0

      resources = tracker.action_resources || {}
      spell_slots_used = resources['spell_slots_used'] || {}

      level_key = spell_level_key(spell_level)
      spell_slots_used[level_key] = (spell_slots_used[level_key] || 0) + 1
      resources['spell_slots_used'] = spell_slots_used

      tracker.action_resources_will_change!
      tracker.action_resources = resources
      tracker.save!
    end

    # Convert spell level to key format
    def spell_level_key(level)
      case level
      when 1 then '1st'
      when 2 then '2nd'
      when 3 then '3rd'
      else "#{level}th"
      end
    end

    # Reset death saves
    def reset_death_saves
      death_saves = tracker.death_saves || {}
      death_saves['successes'] = 0
      death_saves['failures'] = 0

      tracker.death_saves_will_change!
      tracker.death_saves = death_saves
      tracker.save!
    end

    # Log action to combat tracker
    def log_action(action_type, details)
      resources = tracker.action_resources || {}
      combat_log = resources['combat_log'] || []

      combat_log << {
        action_type: action_type,
        timestamp: Time.current.iso8601,
        details: details
      }

      # Keep last 100 entries
      combat_log = combat_log.last(100)

      resources['combat_log'] = combat_log

      tracker.action_resources_will_change!
      tracker.action_resources = resources
      tracker.save!
    end
  end
end
