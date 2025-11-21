# frozen_string_literal: true

module CharacterFeatures
  module Sheet
    class CharacterSheetsController < ApplicationController
      def show
        authorize @character_features::sheet::character_sheets
      end

      def update_hp
        # TODO: Implement update_hp
      end

      def roll_ability_check
        # TODO: Implement roll_ability_check
      end

      def roll_saving_throw
        # TODO: Implement roll_saving_throw
      end

      def roll_skill_check
        # TODO: Implement roll_skill_check
      end

      def roll_death_save
        # TODO: Implement roll_death_save
      end

      def reset_death_saves
        # TODO: Implement reset_death_saves
      end

      def add_condition
        # TODO: Implement add_condition
      end

      def remove_condition
        # TODO: Implement remove_condition
      end

      def start_concentration
        # TODO: Implement start_concentration
      end

      private

      def set_character_features::sheet::character_sheets
        @character_features::sheet::character_sheets = CharacterFeatures::sheet::characterSheets.find(params[:id])
      end

      def character_features::sheet::character_sheets_params
        params.require(:character_features::sheet::character_sheets).permit()
      end

    end
  end
end