# frozen_string_literal: true

module CharacterFeatures
  module Combat
    class CombatTrackerController < ApplicationController
      def show
        authorize @character_features::combat::combat_tracker
      end

      def start_combat
        # TODO: Implement start_combat
      end

      private

      def set_character_features::combat::combat_tracker
        @character_features::combat::combat_tracker = CharacterFeatures::combat::combatTracker.find(params[:id])
      end

      def character_features::combat::combat_tracker_params
        params.require(:character_features::combat::combat_tracker).permit()
      end

    end
  end
end