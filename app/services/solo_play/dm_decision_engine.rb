# frozen_string_literal: true

module SoloPlay
  class DmDecisionEngine

    def on_player_action(action_type:, context:)
      # TODO: Implement
    end

    def on_dice_roll(roll_result:, dc:, context:)
      # TODO: Implement
    end

    def on_hp_change(character, old_hp, new_hp)
      # TODO: Implement
    end

    def on_rest_request(rest_type:, context:)
      # TODO: Implement
    end

    def on_rule_violation(attempted_action:, reason:, character_speed: nil)
      # TODO: Implement
    end

    def should_initiate_combat
      # TODO: Implement
    end

    def should_spawn_npc
      # TODO: Implement
    end

    def validate_action_legality(action:, character_state:, spell_level: nil)
      # TODO: Implement
    end

    def calculate_dc(task_difficulty:, environmental_factors:)
      # TODO: Implement
    end

    def determine_consequences(player_choice:, world_state:)
      # TODO: Implement
    end
  end
end