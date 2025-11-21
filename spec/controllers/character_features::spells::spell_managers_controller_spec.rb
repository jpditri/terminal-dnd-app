# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::Spells::CharacterFeatures::spells::spellManagersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::spells::spell_managers) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::spells::spell_managers = create(:character_features::spells::spell_managers)
      get :show, params: { id: character_features::spells::spell_managers.to_param }
      expect(response).to be_successful
    end
  end







end