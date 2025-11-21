# frozen_string_literal: true

# CharacterSpellManager - Manages spellcasting for D&D 5e characters
# Ported from heretical-web-app with adaptations for terminal-dnd
#
# Key Features:
# - Spell slot calculation by level (including multiclass)
# - Spell preparation limits based on class and ability modifier
# - Concentration tracking (only one spell at a time)
# - Ritual casting (no slot required, +10 minutes cast time)
# - Cantrip damage scaling at levels 5, 11, 17
# - Spellbook management for prepared casters (Wizards)
# - Metamagic system for Sorcerers
# - Wild Magic surge mechanics
#
# IMPORTANT: This model uses JSONB columns for spell_slots and other attributes.
# When mutating JSONB hashes in place, we MUST call {attribute}_will_change!
# before the mutation to ensure Rails tracks and persists the changes.
class CharacterSpellManager < ApplicationRecord
  belongs_to :character

  # Validations
  validates :character_id, presence: true, uniqueness: true
  validates :spellcasting_ability,
            inclusion: { in: %w[intelligence wisdom charisma], allow_nil: true }

  # JSONB default values are handled by migration, but we ensure proper structure
  attribute :spell_slots, :jsonb, default: {}
  attribute :prepared_spells, :jsonb, default: []
  attribute :known_spells, :jsonb, default: []
  attribute :ritual_spells, :jsonb, default: []
  attribute :spell_book, :jsonb, default: []
  attribute :concentration, :jsonb, default: {}
  attribute :known_metamagics, :jsonb, default: []
  attribute :metamagic_options, :jsonb, default: {}

  # ========================================
  # SPELL PREPARATION
  # ========================================

  # Calculate maximum number of spells a character can prepare
  # Formula: Spellcasting Level + Ability Modifier (minimum 1)
  def max_prepared_spells
    return 0 unless spellcasting_ability.present?

    caster_level = character.level || 1
    ability_mod = character.send("#{spellcasting_ability}_modifier")

    [caster_level + ability_mod, 1].max
  end

  # Check if character can prepare more spells
  def can_prepare_more_spells?
    prepared_spells.size < max_prepared_spells
  end

  # Prepare a spell (add to prepared list)
  def prepare_spell(spell_id)
    return { success: false, error: "Spell already prepared" } if spell_prepared?(spell_id)
    return { success: false, error: "Maximum spells prepared" } unless can_prepare_more_spells?
    return { success: false, error: "Spell not in spellbook" } unless spell_in_spellbook?(spell_id)

    self.prepared_spells = (prepared_spells + [spell_id]).uniq
    save ? { success: true } : { success: false, error: errors.full_messages.join(", ") }
  end

  # Unprepare a spell (remove from prepared list)
  def unprepare_spell(spell_id)
    return { success: false, error: "Spell not prepared" } unless spell_prepared?(spell_id)

    self.prepared_spells = prepared_spells - [spell_id]
    save ? { success: true } : { success: false, error: errors.full_messages.join(", ") }
  end

  # Check if a spell is prepared
  def spell_prepared?(spell_id)
    prepared_spells.include?(spell_id)
  end

  # Check if a spell is in the spellbook (for Wizards)
  def spell_in_spellbook?(spell_id)
    spell_book.include?(spell_id) || known_spells.include?(spell_id)
  end

  # ========================================
  # SPELL SLOT TRACKING
  # ========================================

  # Initialize spell slots based on character level and class
  # Note: In terminal-dnd, we'll use a simpler calculation until SpellSlotCalculator is ported
  def initialize_spell_slots
    # Simple calculation based on class and level
    # This will be enhanced when SpellSlotCalculator service is ported
    slots = calculate_spell_slots_for_level(character.level || 1)
    self.spell_slots = slots
    save
  end

  # Get total slots for a given spell level
  def total_slots_for_level(spell_level)
    spell_slots.dig(spell_level.to_s, "total") || 0
  end

  # Get used slots for a given spell level
  def used_slots_for_level(spell_level)
    spell_slots.dig(spell_level.to_s, "used") || 0
  end

  # Get available slots for a given spell level
  def available_slots_for_level(spell_level)
    # Ensure spell_slots is never nil (defensive programming)
    return 0 if spell_slots.nil? || spell_slots.empty?

    total = total_slots_for_level(spell_level)
    used = used_slots_for_level(spell_level)
    [total - used, 0].max
  end

  # Check if slots are available for a spell level
  def has_available_slot?(spell_level)
    available_slots_for_level(spell_level) > 0
  end

  # Use a spell slot
  def use_spell_slot(spell_level)
    return { success: false, error: "No slots available" } unless has_available_slot?(spell_level)

    current_used = used_slots_for_level(spell_level)
    # Mark JSONB attribute as changed before mutating
    spell_slots_will_change!
    spell_slots[spell_level.to_s] ||= {}
    spell_slots[spell_level.to_s]["used"] = current_used + 1

    save ? { success: true } : { success: false, error: errors.full_messages.join(", ") }
  end

  # Restore a spell slot (if cast was cancelled or counterspelled)
  def restore_spell_slot(spell_level)
    current_used = used_slots_for_level(spell_level)
    return { success: false, error: "No slots to restore" } if current_used.zero?

    # Mark JSONB attribute as changed before mutating
    spell_slots_will_change!
    spell_slots[spell_level.to_s]["used"] = current_used - 1
    save ? { success: true } : { success: false, error: errors.full_messages.join(", ") }
  end

  # Restore all spell slots (long rest)
  def restore_all_spell_slots
    updated_slots = spell_slots.deep_dup
    updated_slots.each do |level, data|
      updated_slots[level]["used"] = 0
    end
    self.spell_slots = updated_slots
    save
  end

  # Get all spell slot information as an array
  def spell_slots_summary
    (1..9).map do |level|
      {
        level: level,
        total: total_slots_for_level(level),
        used: used_slots_for_level(level),
        available: available_slots_for_level(level)
      }
    end.reject { |slot| slot[:total].zero? }
  end

  # ========================================
  # CONCENTRATION
  # ========================================

  # Start concentrating on a spell
  def start_concentration(spell_id, duration_minutes = nil)
    # End previous concentration if active
    end_concentration if concentrating?

    self.concentration = {
      "spell_id" => spell_id,
      "started_at" => Time.current.to_i,
      "duration_minutes" => duration_minutes
    }
    save
  end

  # End concentration
  def end_concentration
    self.concentration = {}
    save
  end

  # Check if currently concentrating
  def concentrating?
    concentration.present? && concentration["spell_id"].present?
  end

  # Get current concentration spell ID
  def concentration_spell_id
    concentration["spell_id"]
  end

  # Calculate concentration save DC when taking damage
  # DC = 10 or half the damage taken, whichever is higher
  def concentration_save_dc(damage_taken)
    [10, (damage_taken / 2.0).ceil].max
  end

  # Check concentration save
  def check_concentration_save(damage_taken, roll_result = nil)
    return { success: true, message: "Not concentrating" } unless concentrating?

    dc = concentration_save_dc(damage_taken)

    if roll_result.nil?
      # Return DC for manual rolling
      { requires_save: true, dc: dc, ability: "constitution" }
    else
      # Check if save succeeded
      # Note: Character#saving_throw needs to be implemented
      save_bonus = character.respond_to?(:saving_throw) ? character.saving_throw(:constitution) : character.constitution_modifier
      total = roll_result + save_bonus

      if total >= dc
        { success: true, saved: true, total: total, dc: dc }
      else
        end_concentration
        { success: true, saved: false, total: total, dc: dc, concentration_broken: true }
      end
    end
  end

  # ========================================
  # RITUAL CASTING
  # ========================================

  # Check if a spell can be cast as a ritual
  def can_cast_as_ritual?(spell_id)
    ritual_spells.include?(spell_id)
  end

  # Cast a spell as a ritual (no slot consumed, +10 minutes)
  def cast_as_ritual(spell_id)
    return { success: false, error: "Not a ritual spell" } unless can_cast_as_ritual?(spell_id)
    unless spell_prepared?(spell_id) || spell_in_spellbook?(spell_id)
      return { success: false,
               error: "Spell not prepared or known" }
    end

    {
      success: true,
      casting_time_modifier: "10 minutes",
      slot_consumed: false
    }
  end

  # Add a spell to ritual spells list
  def add_ritual_spell(spell_id)
    self.ritual_spells = (ritual_spells + [spell_id]).uniq
    save
  end

  # ========================================
  # SPELLBOOK MANAGEMENT
  # ========================================

  # Add spell to spellbook (for Wizards)
  def add_to_spellbook(spell_id)
    return { success: false, error: "Spell already in spellbook" } if spell_book.include?(spell_id)

    self.spell_book = (spell_book + [spell_id]).uniq
    save ? { success: true } : { success: false, error: errors.full_messages.join(", ") }
  end

  # Remove spell from spellbook
  def remove_from_spellbook(spell_id)
    # Also unprepare if prepared
    unprepare_spell(spell_id) if spell_prepared?(spell_id)

    self.spell_book = spell_book - [spell_id]
    save ? { success: true } : { success: false, error: errors.full_messages.join(", ") }
  end

  # Add spell to known spells (for non-prepared casters like Sorcerers)
  def add_known_spell(spell_id)
    return { success: false, error: "Spell already known" } if known_spells.include?(spell_id)

    self.known_spells = (known_spells + [spell_id]).uniq
    save ? { success: true } : { success: false, error: errors.full_messages.join(", ") }
  end

  # Remove spell from known spells
  def remove_known_spell(spell_id)
    self.known_spells = known_spells - [spell_id]
    save ? { success: true } : { success: false, error: errors.full_messages.join(", ") }
  end

  # ========================================
  # CANTRIPS
  # ========================================

  # Calculate cantrip damage dice based on character level
  # Cantrips scale at levels 5, 11, and 17
  def cantrip_damage_dice(base_dice = 1)
    level = character.level || 1

    case level
    when 1..4
      base_dice
    when 5..10
      base_dice * 2
    when 11..16
      base_dice * 3
    when 17..20
      base_dice * 4
    else
      base_dice
    end
  end

  # ========================================
  # SPELL SAVE DC & ATTACK BONUS
  # ========================================

  # Calculate spell save DC
  # Formula: 8 + proficiency bonus + ability modifier
  def calculate_spell_save_dc
    return nil unless spellcasting_ability.present?

    proficiency = character.respond_to?(:proficiency_value) ? character.proficiency_value : calculate_proficiency_bonus
    8 + proficiency + character.send("#{spellcasting_ability}_modifier")
  end

  # Calculate spell attack bonus
  # Formula: proficiency bonus + ability modifier
  def calculate_spell_attack_bonus
    return nil unless spellcasting_ability.present?

    proficiency = character.respond_to?(:proficiency_value) ? character.proficiency_value : calculate_proficiency_bonus
    proficiency + character.send("#{spellcasting_ability}_modifier")
  end

  # Update spell save DC and attack bonus
  def update_spell_stats
    self.spell_save_dc = calculate_spell_save_dc
    self.spell_attack_bonus = calculate_spell_attack_bonus
    save
  end

  # ========================================
  # CASTING HELPERS
  # ========================================

  # Cast a spell (handles slot consumption, concentration, etc.)
  def cast_spell(spell_id, spell_level, options = {})
    ritual = options[:ritual] || false
    requires_concentration = options[:concentration] || false

    # Handle ritual casting
    if ritual
      result = cast_as_ritual(spell_id)
      return result unless result[:success]
    else
      # Cantrips don't consume slots
      unless options[:cantrip]
        slot_result = use_spell_slot(spell_level)
        return slot_result unless slot_result[:success]
      end
    end

    # Handle concentration
    start_concentration(spell_id, options[:duration]) if requires_concentration

    {
      success: true,
      spell_id: spell_id,
      level: spell_level,
      ritual: ritual,
      concentration: requires_concentration
    }
  end

  # ========================================
  # METAMAGIC (SORCERER)
  # ========================================

  # D&D 5e Metamagic Options
  METAMAGIC_OPTIONS = {
    "quickened" => {
      cost: 2,
      description: "Cast spell as bonus action instead of action",
      effect: :quickened_spell
    },
    "twinned" => {
      cost_formula: ->(spell_level) { spell_level.positive? ? spell_level : 1 },
      description: "Target a second creature with the spell",
      effect: :twinned_spell
    },
    "empowered" => {
      cost: 1,
      description: "Reroll damage dice (Charisma modifier worth)",
      effect: :empowered_spell
    },
    "heightened" => {
      cost: 3,
      description: "One target has disadvantage on save",
      effect: :heightened_spell
    },
    "subtle" => {
      cost: 1,
      description: "Cast without verbal or somatic components",
      effect: :subtle_spell
    },
    "extended" => {
      cost: 1,
      description: "Double spell duration (max 24 hours)",
      effect: :extended_spell
    },
    "careful" => {
      cost: 1,
      description: "Allies auto-succeed on spell save",
      effect: :careful_spell
    },
    "distant" => {
      cost: 1,
      description: "Double spell range (touch becomes 30 ft)",
      effect: :distant_spell
    }
  }.freeze

  # Calculate max sorcery points based on Sorcerer level
  # Formula: Sorcerer level (D&D 5e PHB)
  def calculate_max_sorcery_points
    return 0 unless character.character_class&.name == "Sorcerer"

    character.level || 0
  end

  # Update max sorcery points based on current level
  def update_sorcery_points_max
    self.sorcery_points_max = calculate_max_sorcery_points
    # Initialize current points if first time
    self.sorcery_points_current = sorcery_points_max if sorcery_points_current.nil?
    save
  end

  # Check if character has enough sorcery points
  def has_sorcery_points?(amount)
    sorcery_points_current >= amount
  end

  # Spend sorcery points
  def spend_sorcery_points(amount)
    return { success: false, error: "Not enough sorcery points" } unless has_sorcery_points?(amount)

    self.sorcery_points_current -= amount
    if save
      { success: true,
        remaining: sorcery_points_current }
    else
      { success: false, error: errors.full_messages.join(", ") }
    end
  end

  # Restore sorcery points (long rest restores all)
  def restore_sorcery_points(amount = nil)
    if amount.nil?
      # Full restore on long rest
      self.sorcery_points_current = sorcery_points_max
    else
      # Partial restore (e.g., from converting spell slots)
      self.sorcery_points_current = [sorcery_points_current + amount, sorcery_points_max].min
    end
    save
  end

  # Calculate metamagic cost for a specific spell
  def calculate_metamagic_cost(metamagic_type, spell_level = 0)
    return 0 unless METAMAGIC_OPTIONS.key?(metamagic_type)

    option = METAMAGIC_OPTIONS[metamagic_type]

    if option[:cost_formula]
      # Twinned Spell uses spell level
      option[:cost_formula].call(spell_level)
    else
      # Fixed cost
      option[:cost]
    end
  end

  # Check if character knows a metamagic option
  def knows_metamagic?(metamagic_type)
    known_metamagics.include?(metamagic_type)
  end

  # Learn a new metamagic option
  def learn_metamagic(metamagic_type)
    return { success: false, error: "Invalid metamagic type" } unless METAMAGIC_OPTIONS.key?(metamagic_type)
    return { success: false, error: "Already know this metamagic" } if knows_metamagic?(metamagic_type)

    self.known_metamagics = (known_metamagics + [metamagic_type]).uniq
    save ? { success: true } : { success: false, error: errors.full_messages.join(", ") }
  end

  # Forget a metamagic option (when retraining)
  def forget_metamagic(metamagic_type)
    self.known_metamagics = known_metamagics - [metamagic_type]
    save
  end

  # Check if metamagic can be applied to a spell
  def can_apply_metamagic?(metamagic_types, spell_level = 0)
    # Must be an array
    metamagic_types = Array(metamagic_types)

    # Check if character knows all metamagics
    unknown_metamagics = metamagic_types.reject { |m| knows_metamagic?(m) }
    if unknown_metamagics.any?
      return { success: false,
               error: "Don't know metamagic: #{unknown_metamagics.join(', ')}" }
    end

    # Calculate total cost
    total_cost = metamagic_types.sum { |m| calculate_metamagic_cost(m, spell_level) }

    # Check if enough sorcery points
    unless has_sorcery_points?(total_cost)
      return { success: false,
               error: "Not enough sorcery points (need #{total_cost}, have #{sorcery_points_current})" }
    end

    { success: true, cost: total_cost, metamagics: metamagic_types }
  end

  # Apply metamagic to a spell cast
  def apply_metamagic(spell_id, spell_level, metamagic_types)
    # Validate and calculate cost
    validation = can_apply_metamagic?(metamagic_types, spell_level)
    return validation unless validation[:success]

    # Spend sorcery points
    spend_result = spend_sorcery_points(validation[:cost])
    return spend_result unless spend_result[:success]

    # Build metamagic effects
    effects = build_metamagic_effects(metamagic_types, spell_level)

    {
      success: true,
      spell_id: spell_id,
      metamagics_applied: metamagic_types,
      cost: validation[:cost],
      effects: effects,
      sorcery_points_remaining: sorcery_points_current
    }
  end

  # Build effects hash for metamagic options
  def build_metamagic_effects(metamagic_types, spell_level)
    effects = {}

    metamagic_types.each do |metamagic|
      case metamagic
      when "quickened"
        effects[:casting_time] = "bonus action"
      when "twinned"
        effects[:additional_targets] = 1
      when "empowered"
        effects[:reroll_dice_count] = character.charisma_modifier
      when "heightened"
        effects[:target_disadvantage] = true
      when "subtle"
        effects[:no_components] = ["verbal", "somatic"]
      when "extended"
        effects[:duration_multiplier] = 2
      when "careful"
        effects[:allies_auto_save] = true
      when "distant"
        effects[:range_multiplier] = 2
        effects[:touch_becomes] = "30 ft"
      end
    end

    effects
  end

  # Convert spell slots to sorcery points
  # Cost: slot level = sorcery points gained
  def convert_spell_slot_to_sorcery_points(spell_level)
    return { success: false, error: "No slots available" } unless has_available_slot?(spell_level)
    return { success: false, error: "Cannot exceed max sorcery points" } if sorcery_points_current >= sorcery_points_max

    # Use the spell slot
    slot_result = use_spell_slot(spell_level)
    return slot_result unless slot_result[:success]

    # Gain sorcery points (limited to max)
    points_to_gain = [spell_level, sorcery_points_max - sorcery_points_current].min
    restore_sorcery_points(points_to_gain)

    {
      success: true,
      points_gained: points_to_gain,
      sorcery_points_current: sorcery_points_current
    }
  end

  # Convert sorcery points to spell slots
  # Cost: D&D 5e PHB table (1st=2pts, 2nd=3pts, 3rd=5pts, 4th=6pts, 5th=7pts)
  SPELL_SLOT_CREATION_COSTS = {
    1 => 2,
    2 => 3,
    3 => 5,
    4 => 6,
    5 => 7
  }.freeze

  def convert_sorcery_points_to_spell_slot(spell_level)
    cost = SPELL_SLOT_CREATION_COSTS[spell_level]
    return { success: false, error: "Can only create slots of level 1-5" } unless cost

    return { success: false, error: "Not enough sorcery points (need #{cost})" } unless has_sorcery_points?(cost)

    # Spend sorcery points
    spend_result = spend_sorcery_points(cost)
    return spend_result unless spend_result[:success]

    # Add temporary spell slot
    # Mark JSONB attribute as changed before mutating
    spell_slots_will_change!
    spell_slots[spell_level.to_s] ||= { "total" => 0, "used" => 0 }
    spell_slots[spell_level.to_s]["total"] += 1
    save

    {
      success: true,
      slot_level: spell_level,
      cost: cost,
      sorcery_points_remaining: sorcery_points_current
    }
  end

  # ========================================
  # WILD MAGIC (WILD MAGIC SORCERER)
  # ========================================

  # Check if wild magic surge should trigger
  # RAW: DM decides, common house rule is d20 roll of 1 after casting 1st level+ spell
  def check_wild_magic_surge(spell_level, roll_result = nil)
    return { triggers: false, message: "Not a leveled spell" } if spell_level.zero?

    if roll_result.nil?
      # Return that a roll is needed
      { requires_roll: true, message: "Roll d20, surge on 1" }
    else
      # Check if surge triggers
      if roll_result == 1
        increment_wild_magic_surge_count
        surge_effect = roll_wild_magic_table
        {
          triggers: true,
          roll: roll_result,
          effect: surge_effect,
          surge_count: wild_magic_surge_count
        }
      else
        { triggers: false, roll: roll_result }
      end
    end
  end

  # Increment wild magic surge counter
  def increment_wild_magic_surge_count
    self.wild_magic_surge_count += 1
    save
  end

  # Roll on wild magic surge table (d100)
  def roll_wild_magic_table(roll_result = nil)
    roll = roll_result || rand(1..100)

    # Wild magic effects table
    # This is a simplified version - full table has 50 effects
    effect = case roll
    when 1..2
      { id: 1, name: "Cast Fireball", description: "Roll 1d10. You cast fireball as 3rd-level centered on yourself" }
    when 3..4
      { id: 2, name: "Maximum Damage",
        description: "You take maximum damage for next spell that deals damage in next minute" }
    when 5..6
      { id: 3, name: "Beard of Feathers",
        description: "You grow a long beard made of feathers that lasts until you sneeze" }
    when 7..8
      { id: 4, name: "Grease", description: "You cast grease centered on yourself" }
    when 9..10
      { id: 5, name: "Spell Recast", description: "You cast a random spell from prepared spells" }
    # ... Continue with remaining 45 effects from PHB
    # For now, using a generic effect
    else
      { id: (roll / 2).ceil, name: "Wild Magic Effect #{roll}",
        description: "Consult Wild Magic Surge table (PHB p.104)" }
    end

    {
      roll: roll,
      effect: effect,
      message: "Wild Magic Surge! #{effect[:name]}: #{effect[:description]}"
    }
  end

  private

  # Calculate proficiency bonus based on character level
  # D&D 5e progression: +2 at level 1-4, +3 at 5-8, +4 at 9-12, +5 at 13-16, +6 at 17-20
  def calculate_proficiency_bonus
    level = character.level || 1
    case level
    when 1..4 then 2
    when 5..8 then 3
    when 9..12 then 4
    when 13..16 then 5
    when 17..20 then 6
    else 2
    end
  end

  # Simple spell slot calculation for full casters
  # This is a temporary implementation until SpellSlotCalculator service is ported
  def calculate_spell_slots_for_level(level)
    # D&D 5e spell slot progression for full casters (Wizard, Cleric, Druid, Sorcerer)
    # Format: { "1" => { "total" => X, "used" => 0 }, ... }
    slots = {}

    case level
    when 1
      slots = { "1" => { "total" => 2, "used" => 0 } }
    when 2
      slots = { "1" => { "total" => 3, "used" => 0 } }
    when 3
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 2, "used" => 0 } }
    when 4
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 } }
    when 5
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 2, "used" => 0 } }
    when 6
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 3, "used" => 0 } }
    when 7
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 3, "used" => 0 }, "4" => { "total" => 1, "used" => 0 } }
    when 8
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 3, "used" => 0 }, "4" => { "total" => 2, "used" => 0 } }
    when 9
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 3, "used" => 0 }, "4" => { "total" => 3, "used" => 0 }, "5" => { "total" => 1, "used" => 0 } }
    when 10
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 3, "used" => 0 }, "4" => { "total" => 3, "used" => 0 }, "5" => { "total" => 2, "used" => 0 } }
    when 11..12
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 3, "used" => 0 }, "4" => { "total" => 3, "used" => 0 }, "5" => { "total" => 2, "used" => 0 }, "6" => { "total" => 1, "used" => 0 } }
    when 13..14
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 3, "used" => 0 }, "4" => { "total" => 3, "used" => 0 }, "5" => { "total" => 2, "used" => 0 }, "6" => { "total" => 1, "used" => 0 }, "7" => { "total" => 1, "used" => 0 } }
    when 15..16
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 3, "used" => 0 }, "4" => { "total" => 3, "used" => 0 }, "5" => { "total" => 2, "used" => 0 }, "6" => { "total" => 1, "used" => 0 }, "7" => { "total" => 1, "used" => 0 }, "8" => { "total" => 1, "used" => 0 } }
    when 17..20
      slots = { "1" => { "total" => 4, "used" => 0 }, "2" => { "total" => 3, "used" => 0 }, "3" => { "total" => 3, "used" => 0 }, "4" => { "total" => 3, "used" => 0 }, "5" => { "total" => 3, "used" => 0 }, "6" => { "total" => 1, "used" => 0 }, "7" => { "total" => 1, "used" => 0 }, "8" => { "total" => 1, "used" => 0 }, "9" => { "total" => 1, "used" => 0 } }
    else
      slots = { "1" => { "total" => 2, "used" => 0 } }
    end

    slots
  end
end
