# frozen_string_literal: true

module CharacterFeatures
  module Combat
    class CombatActionsController < ApplicationController
      def show
        authorize @character_features::combat::combat_actions
      end

      def attack
        # TODO: Implement attack
      end

      def cast_spell
        # TODO: Implement cast_spell
      end

      def dash
        # TODO: Implement dash
      end

      def dodge
        # TODO: Implement dodge
      end

      def help
        # TODO: Implement help
      end

      def hide
        # TODO: Implement hide
      end

      def ready_action
        # TODO: Implement ready_action
      end

      def use_item
        # TODO: Implement use_item
      end

      def opportunity_attack
        # TODO: Implement opportunity_attack
      end

      private

      def set_character_features::combat::combat_actions
        @character_features::combat::combat_actions = CharacterFeatures::combat::combatActions.find(params[:id])
      end

      def character_features::combat::combat_actions_params
        params.require(:character_features::combat::combat_actions).permit()
      end

    end
  end
end