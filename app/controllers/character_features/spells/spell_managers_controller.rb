# frozen_string_literal: true

module CharacterFeatures
  module Spells
    class SpellManagersController < ApplicationController
      def show
        authorize @character_features::spells::spell_managers
      end

      def spellbook
        # TODO: Implement spellbook
      end

      def prepare_spell
        # TODO: Implement prepare_spell
      end

      def unprepare_spell
        # TODO: Implement unprepare_spell
      end

      def cast_spell
        # TODO: Implement cast_spell
      end

      def cast_ritual
        # TODO: Implement cast_ritual
      end

      def concentrate
        # TODO: Implement concentrate
      end

      private

      def set_character_features::spells::spell_managers
        @character_features::spells::spell_managers = CharacterFeatures::spells::spellManagers.find(params[:id])
      end

      def character_features::spells::spell_managers_params
        params.require(:character_features::spells::spell_managers).permit()
      end

    end
  end
end