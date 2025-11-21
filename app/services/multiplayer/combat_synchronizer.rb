# frozen_string_literal: true

module Multiplayer
  class CombatSynchronizer

    def start_combat
      # TODO: Implement
    end

    def sync_initiative
      # TODO: Implement
    end

    def advance_turn
      # TODO: Implement
    end

    def sync_damage(combatant: nil, damage:, damage_type: nil, source: nil, combatant_id: nil)
      # TODO: Implement
    end

    def sync_healing(combatant:, healing:, source: nil)
      # TODO: Implement
    end

    def sync_condition(combatant:, condition:, duration: nil, source: nil)
      # TODO: Implement
    end

    def remove_condition(combatant:, condition:)
      # TODO: Implement
    end

    def sync_death_save(combatant:, roll:, natural: false)
      # TODO: Implement
    end

    def end_combat(victory: true)
      # TODO: Implement
    end

    def pause_combat(reason: nil)
      # TODO: Implement
    end

    def resume_combat
      # TODO: Implement
    end

    def sync_full_state(user)
      # TODO: Implement
    end
  end
end