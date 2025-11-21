# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::Progression::CharacterFeatures::progression::progressionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::progression::progressions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::progression::progressions = create(:character_features::progression::progressions)
      get :show, params: { id: character_features::progression::progressions.to_param }
      expect(response).to be_successful
    end
  end
















end