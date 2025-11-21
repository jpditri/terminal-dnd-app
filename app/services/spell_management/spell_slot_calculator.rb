# frozen_string_literal: true

module SpellManagement
  # Calculates spell slots based on D&D 5e rules
  # Handles single class and multiclass spellcasters
  class SpellSlotCalculator
    # D&D 5e Spell Slots by Level
    SPELL_SLOTS_TABLE = {
      1 => { 1 => 2 },
      2 => { 1 => 3 },
      3 => { 1 => 4, 2 => 2 },
      4 => { 1 => 4, 2 => 3 },
      5 => { 1 => 4, 2 => 3, 3 => 2 },
      6 => { 1 => 4, 2 => 3, 3 => 3 },
      7 => { 1 => 4, 2 => 3, 3 => 3, 4 => 1 },
      8 => { 1 => 4, 2 => 3, 3 => 3, 4 => 2 },
      9 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 1 },
      10 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2 },
      11 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1 },
      12 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1 },
      13 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1 },
      14 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1 },
      15 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1, 8 => 1 },
      16 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1, 8 => 1 },
      17 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 2, 6 => 1, 7 => 1, 8 => 1, 9 => 1 },
      18 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 3, 6 => 1, 7 => 1, 8 => 1, 9 => 1 },
      19 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 3, 6 => 2, 7 => 1, 8 => 1, 9 => 1 },
      20 => { 1 => 4, 2 => 3, 3 => 3, 4 => 3, 5 => 3, 6 => 2, 7 => 2, 8 => 1, 9 => 1 }
    }.freeze

    FULL_CASTERS = %w[wizard cleric druid sorcerer bard].freeze
    HALF_CASTERS = %w[paladin ranger].freeze
    THIRD_CASTERS = %w[eldritch_knight arcane_trickster].freeze
    PACT_MAGIC_CASTERS = %w[warlock].freeze

    PACT_MAGIC_TABLE = {
      1 => { slots: 1, level: 1 }, 2 => { slots: 2, level: 1 },
      3 => { slots: 2, level: 2 }, 4 => { slots: 2, level: 2 },
      5 => { slots: 2, level: 3 }, 6 => { slots: 2, level: 3 },
      7 => { slots: 2, level: 4 }, 8 => { slots: 2, level: 4 },
      9 => { slots: 2, level: 5 }, 10 => { slots: 2, level: 5 },
      11 => { slots: 3, level: 5 }, 12 => { slots: 3, level: 5 },
      13 => { slots: 3, level: 5 }, 14 => { slots: 3, level: 5 },
      15 => { slots: 3, level: 5 }, 16 => { slots: 3, level: 5 },
      17 => { slots: 4, level: 5 }, 18 => { slots: 4, level: 5 },
      19 => { slots: 4, level: 5 }, 20 => { slots: 4, level: 5 }
    }.freeze

    attr_reader :character

    def initialize(character)
      @character = character
    end

    # Calculate spell slots for the character
    def calculate_slots
      class_name = character.character_class&.name&.downcase || "wizard"
      char_level = character.level || 1

      caster_level = calculate_caster_level(class_name, char_level)
      slots = get_spell_slots_for_level(caster_level)
      format_slots(slots)
    end

    # Calculate the effective caster level based on class type
    def calculate_caster_level(class_name, char_level)
      if FULL_CASTERS.include?(class_name)
        char_level
      elsif HALF_CASTERS.include?(class_name)
        (char_level / 2.0).floor
      elsif THIRD_CASTERS.include?(class_name)
        (char_level / 3.0).floor
      elsif PACT_MAGIC_CASTERS.include?(class_name)
        char_level
      else
        char_level
      end
    end

    # Get spell slots for a given caster level
    def get_spell_slots_for_level(caster_level)
      level = [caster_level, 20].min
      return {} if level < 1
      SPELL_SLOTS_TABLE[level] || {}
    end

    # Format slots for JSONB storage
    def format_slots(slots_hash)
      formatted = {}
      slots_hash.each do |spell_level, total_slots|
        formatted[spell_level.to_s] = {
          "total" => total_slots,
          "used" => 0
        }
      end
      formatted
    end

    # Calculate multiclass spell slots
    def self.calculate_multiclass_slots(class_levels)
      total_caster_level = 0

      class_levels.each do |class_info|
        class_name = class_info[:class].downcase
        char_level = class_info[:level]

        if FULL_CASTERS.include?(class_name)
          total_caster_level += char_level
        elsif HALF_CASTERS.include?(class_name)
          total_caster_level += (char_level / 2.0).floor
        elsif THIRD_CASTERS.include?(class_name)
          total_caster_level += (char_level / 3.0).floor
        end
      end

      calculator = new(nil)
      slots = calculator.get_spell_slots_for_level(total_caster_level)
      calculator.format_slots(slots)
    end

    # Get Warlock pact magic slots
    def calculate_pact_magic_slots(warlock_level)
      pact_data = PACT_MAGIC_TABLE[warlock_level] || { slots: 0, level: 1 }

      {
        "pact_magic" => {
          "total" => pact_data[:slots],
          "used" => 0,
          "slot_level" => pact_data[:level]
        }
      }
    end
  end
end
