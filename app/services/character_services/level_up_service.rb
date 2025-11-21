# frozen_string_literal: true

module CharacterServices
  # Handles character level up logic per D&D 5e rules
  class LevelUpService
    attr_reader :character

    def initialize(character)
      @character = character
    end

    def call
      return Result.failure(error: "Already at max level") if character.level >= 20

      new_level = character.level + 1

      # Calculate new HP
      hp_increase = calculate_hp_increase(new_level)

      # Calculate proficiency bonus
      proficiency_bonus = calculate_proficiency_bonus(new_level)

      # Update character
      character.update!(
        level: new_level,
        hit_points_max: character.hit_points_max + hp_increase,
        hit_points_current: character.hit_points_current + hp_increase,
        proficiency_bonus: proficiency_bonus
      )

      # Recalculate spell slots if spellcaster
      if character.spellcaster?
        calculator = SpellManagement::SpellSlotCalculator.new(character)
        character.update!(spell_slots: calculator.calculate_slots)
      end

      Result.success(
        character: character,
        hp_increase: hp_increase,
        new_level: new_level,
        features: get_new_features(new_level)
      )
    end

    private

    def calculate_hp_increase(new_level)
      hit_die = character.character_class&.hit_die || 8
      con_modifier = (character.constitution - 10) / 2

      # Average roll + constitution modifier
      (hit_die / 2) + 1 + con_modifier
    end

    def calculate_proficiency_bonus(level)
      ((level - 1) / 4) + 2
    end

    def get_new_features(level)
      # Would query class features for this level
      []
    end
  end
end
