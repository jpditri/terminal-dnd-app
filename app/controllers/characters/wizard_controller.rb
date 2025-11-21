# frozen_string_literal: true

module Characters
  class WizardController < ApplicationController
    before_action :ensure_wizard_session, except: [:reset]
    before_action :initialize_wizard_session, only: [:start]
    before_action :load_wizard_data, except: [:start, :reset]

    def start
      # TODO: Implement start
    end

    def race
      # TODO: Implement race
    end

    def post_race
      # TODO: Implement post_race
    end

    def select_class
      # TODO: Implement select_class
    end

    def post_select_class
      # TODO: Implement post_select_class
    end

    def background
      # TODO: Implement background
    end

    def post_background
      # TODO: Implement post_background
    end

    def abilities
      # TODO: Implement abilities
    end

    def post_abilities
      # TODO: Implement post_abilities
    end

    def feats
      # TODO: Implement feats
    end

    def post_feats
      # TODO: Implement post_feats
    end

    def equipment
      # TODO: Implement equipment
    end

    def post_equipment
      # TODO: Implement post_equipment
    end

    def spells
      # TODO: Implement spells
    end

    def post_spells
      # TODO: Implement post_spells
    end

    def review
      # TODO: Implement review
    end

    def create_character
      # TODO: Implement create_character
    end

    def reset
      # TODO: Implement reset
    end

    def ensure_wizard_session
      # TODO: Implement ensure_wizard_session
    end

    def initialize_wizard_session
      # TODO: Implement initialize_wizard_session
    end

    def load_wizard_data
      # TODO: Implement load_wizard_data
    end

    private

    def set_characters::wizard
      @characters::wizard = Characters::wizard.find(params[:id])
    end

    def characters::wizard_params
      params.require(:characters::wizard).permit()
    end

  end
end