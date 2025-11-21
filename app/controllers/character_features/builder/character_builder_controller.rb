# frozen_string_literal: true

module CharacterFeatures
  module Builder
    class CharacterBuilderController < ApplicationController
      before_action :load_builder_session
      before_action :load_reference_data

      def new
        @character_features::builder::character_builder = CharacterFeatures::builder::characterBuilder.new
        authorize @character_features::builder::character_builder
      end

      def create
        @character_features::builder::character_builder = CharacterFeatures::builder::characterBuilder.new(character_features::builder::character_builder_params)
        authorize @character_features::builder::character_builder

        respond_to do |format|
          if @character_features::builder::character_builder.save
            format.html { redirect_to @character_features::builder::character_builder, notice: 'CharacterFeatures::builder::characterBuilder was successfully created.' }
            format.turbo_stream
          else
            format.html { render :new, status: :unprocessable_entity }
          end
        end
      end

      def quick_build
        # TODO: Implement quick_build
      end

      def race_selection
        # TODO: Implement race_selection
      end

      def select_subrace
        # TODO: Implement select_subrace
      end

      def class_selection
        # TODO: Implement class_selection
      end

      def abilities
        # TODO: Implement abilities
      end

      def background_selection
        # TODO: Implement background_selection
      end

      def skills_selection
        # TODO: Implement skills_selection
      end

      def equipment_selection
        # TODO: Implement equipment_selection
      end

      def backstory
        # TODO: Implement backstory
      end

      def review
        # TODO: Implement review
      end

      def apply_template
        # TODO: Implement apply_template
      end

      def select_race
        # TODO: Implement select_race
      end

      def submit_subrace
        # TODO: Implement submit_subrace
      end

      def select_class
        # TODO: Implement select_class
      end

      def select_background
        # TODO: Implement select_background
      end

      def roll_abilities
        # TODO: Implement roll_abilities
      end

      def point_buy
        # TODO: Implement point_buy
      end

      def select_skills
        # TODO: Implement select_skills
      end

      def select_equipment
        # TODO: Implement select_equipment
      end

      def roll_starting_wealth
        # TODO: Implement roll_starting_wealth
      end

      def generate_backstory
        # TODO: Implement generate_backstory
      end

      def validate_build
        # TODO: Implement validate_build
      end

      def save_character
        # TODO: Implement save_character
      end

      def random_character
        # TODO: Implement random_character
      end

      def analyze_build
        # TODO: Implement analyze_build
      end

      def export
        # TODO: Implement export
      end

      def load_builder_session
        # TODO: Implement load_builder_session
      end

      def load_reference_data
        # TODO: Implement load_reference_data
      end

      private

      def set_character_features::builder::character_builder
        @character_features::builder::character_builder = CharacterFeatures::builder::characterBuilder.find(params[:id])
      end

      def character_features::builder::character_builder_params
        params.require(:character_features::builder::character_builder).permit()
      end

    end
  end
end