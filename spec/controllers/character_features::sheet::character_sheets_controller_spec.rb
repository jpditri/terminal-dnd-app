# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::Sheet::CharacterFeatures::sheet::characterSheetsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::sheet::character_sheets) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::sheet::character_sheets = create(:character_features::sheet::character_sheets)
      get :show, params: { id: character_features::sheet::character_sheets.to_param }
      expect(response).to be_successful
    end
  end










end