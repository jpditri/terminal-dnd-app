# frozen_string_literal: true

module CharacterServices
  # Handles short and long rest mechanics per D&D 5e rules
  class RestService
    attr_reader :character

    def initialize(character)
      @character = character
    end

    def short_rest(hit_dice_to_spend: 0)
      return Result.failure(error: "Invalid hit dice count") if hit_dice_to_spend < 0

      available_hit_dice = character.hit_dice_remaining || character.level
      dice_to_spend = [hit_dice_to_spend, available_hit_dice].min

      hp_regained = 0

      dice_to_spend.times do
        hit_die = character.character_class&.hit_die || 8
        con_modifier = (character.constitution - 10) / 2
        roll = rand(1..hit_die) + con_modifier
        hp_regained += [roll, 0].max
      end

      new_hp = [character.hit_points_current + hp_regained, character.hit_points_max].min

      character.update!(
        hit_points_current: new_hp,
        hit_dice_remaining: available_hit_dice - dice_to_spend
      )

      Result.success(
        hp_regained: hp_regained,
        hit_dice_spent: dice_to_spend,
        hit_dice_remaining: available_hit_dice - dice_to_spend
      )
    end

    def long_rest
      # Restore all HP
      character.update!(hit_points_current: character.hit_points_max)

      # Restore half of hit dice (minimum 1)
      hit_dice_to_restore = [character.level / 2, 1].max
      new_hit_dice = [
        (character.hit_dice_remaining || 0) + hit_dice_to_restore,
        character.level
      ].min

      character.update!(hit_dice_remaining: new_hit_dice)

      # Restore all spell slots
      if character.spellcaster?
        calculator = SpellManagement::SpellSlotCalculator.new(character)
        character.update!(spell_slots: calculator.calculate_slots)
      end

      # Clear temporary conditions
      character.conditions&.where(duration_type: 'until_long_rest')&.destroy_all

      Result.success(
        hp_restored: character.hit_points_max - character.hit_points_current,
        hit_dice_restored: hit_dice_to_restore,
        spell_slots_restored: true
      )
    end
  end
end
