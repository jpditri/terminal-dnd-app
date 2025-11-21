# frozen_string_literal: true

module SoloPlay
  # Manages combat flow for solo D&D sessions
  class CombatManager
    attr_reader :combat, :dice_roller

    def initialize(combat, dice_roller: DiceRoller.new)
      @combat = combat
      @dice_roller = dice_roller
    end

    def start_combat
      return Result.failure(error: "Combat already active") if combat.active?

      # Roll initiative for all participants
      combat.participants.each do |participant|
        initiative = roll_initiative(participant)
        participant.update!(initiative: initiative)
      end

      # Sort by initiative (descending)
      combat.update!(
        status: :active,
        round: 1,
        current_turn_index: 0
      )

      Result.success(
        combat: combat,
        turn_order: combat.participants.order(initiative: :desc)
      )
    end

    def next_turn
      return Result.failure(error: "Combat not active") unless combat.active?

      current_index = combat.current_turn_index
      participants = combat.participants.order(initiative: :desc)

      # Move to next participant
      new_index = (current_index + 1) % participants.count

      # New round if we've cycled through everyone
      new_round = combat.round
      if new_index == 0
        new_round += 1
      end

      combat.update!(
        current_turn_index: new_index,
        round: new_round
      )

      Result.success(
        current_participant: participants[new_index],
        round: new_round,
        turn: new_index + 1
      )
    end

    def end_combat
      combat.update!(status: :completed)
      Result.success(combat: combat, rounds: combat.round)
    end

    # Alias for compatibility with ToolExecutor
    def end_combat!
      result = end_combat
      {
        combat_id: combat.id,
        final_round: combat.round,
        status: combat.status
      }
    end

    # Get current combat state for AI DM
    def get_combat_state
      participants = combat.combat_participants.includes(:character, :npc, :encounter_monster).order(initiative: :desc)

      {
        round: combat.current_round || 1,
        turn: combat.current_turn || 0,
        current_participant: current_participant_name,
        participants: participants.map do |p|
          {
            name: participant_name(p),
            current_hp: p.current_hit_points || 0,
            max_hp: p.max_hit_points || 0,
            armor_class: p.armor_class || 10,
            initiative: p.initiative || 0,
            is_dead: (p.current_hit_points || 0) <= 0,
            conditions: p.conditions || []
          }
        end
      }
    end

    private

    def roll_initiative(participant)
      dex_modifier = if participant.respond_to?(:dexterity)
        (participant.dexterity - 10) / 2
      else
        0
      end

      dice_roller.roll_d20 + dex_modifier
    end

    def current_participant_name
      participants = combat.combat_participants.order(initiative: :desc)
      current_turn_index = combat.current_turn || 0
      return 'Unknown' if participants.empty? || current_turn_index >= participants.count

      participant_name(participants[current_turn_index])
    end

    def participant_name(participant)
      if participant.character
        participant.character.name
      elsif participant.npc
        participant.npc.name
      elsif participant.encounter_monster
        participant.encounter_monster.monster&.name || 'Monster'
      else
        participant.name || 'Unknown'
      end
    end
  end
end
