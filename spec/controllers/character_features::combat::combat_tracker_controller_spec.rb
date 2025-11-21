# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::Combat::CharacterFeatures::combat::combatTrackerController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::combat::combat_tracker) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::combat::combat_tracker = create(:character_features::combat::combat_tracker)
      get :show, params: { id: character_features::combat::combat_tracker.to_param }
      expect(response).to be_successful
    end
  end


end