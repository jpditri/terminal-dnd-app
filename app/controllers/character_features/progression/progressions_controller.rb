# frozen_string_literal: true

module CharacterFeatures
  module Progression
    class ProgressionsController < ApplicationController
      before_action :set_character
      before_action :set_progression
      before_action :authorize_character

      def show
        authorize @character_features::progression::progressions
      end

      def add_experience
        # TODO: Implement add_experience
      end

      def level_up
        # TODO: Implement level_up
      end

      def roll_hit_points
        # TODO: Implement roll_hit_points
      end

      def ability_score_improvement
        # TODO: Implement ability_score_improvement
      end

      def select_feat
        # TODO: Implement select_feat
      end

      def multiclass
        # TODO: Implement multiclass
      end

      def select_subclass
        # TODO: Implement select_subclass
      end

      def level_roadmap
        # TODO: Implement level_roadmap
      end

      def level_history
        # TODO: Implement level_history
      end

      def milestone_level
        # TODO: Implement milestone_level
      end

      def analyze_build
        # TODO: Implement analyze_build
      end

      def toggle_progression_type
        # TODO: Implement toggle_progression_type
      end

      def set_character
        # TODO: Implement set_character
      end

      def set_progression
        # TODO: Implement set_progression
      end

      def authorize_character
        # TODO: Implement authorize_character
      end

      private

      def set_character_features::progression::progressions
        @character_features::progression::progressions = CharacterFeatures::progression::progressions.find(params[:id])
      end

      def character_features::progression::progressions_params
        params.require(:character_features::progression::progressions).permit()
      end

    end
  end
end