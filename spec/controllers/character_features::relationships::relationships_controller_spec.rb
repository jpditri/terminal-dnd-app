# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::Relationships::CharacterFeatures::relationships::relationshipsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::relationships::relationships) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:character_features::relationships::relationships)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::relationships::relationships = create(:character_features::relationships::relationships)
      get :show, params: { id: character_features::relationships::relationships.to_param }
      expect(response).to be_successful
    end
  end

























end