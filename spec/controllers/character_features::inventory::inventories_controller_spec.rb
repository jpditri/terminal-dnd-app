# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::Inventory::CharacterFeatures::inventory::inventoriesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::inventory::inventories) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::inventory::inventories = create(:character_features::inventory::inventories)
      get :show, params: { id: character_features::inventory::inventories.to_param }
      expect(response).to be_successful
    end
  end















end