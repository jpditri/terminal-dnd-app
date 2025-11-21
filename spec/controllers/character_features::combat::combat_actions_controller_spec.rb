# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::Combat::CharacterFeatures::combat::combatActionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::combat::combat_actions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::combat::combat_actions = create(:character_features::combat::combat_actions)
      get :show, params: { id: character_features::combat::combat_actions.to_param }
      expect(response).to be_successful
    end
  end










end