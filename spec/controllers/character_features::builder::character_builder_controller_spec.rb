# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::Builder::CharacterFeatures::builder::characterBuilderController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::builder::character_builder) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new CharacterFeatures::builder::characterBuilder' do
        expect {
          post :create, params: { character_features::builder::character_builder: valid_attributes }
        }.to change(CharacterFeatures::builder::characterBuilder, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CharacterFeatures::builder::characterBuilder' do
        expect {
          post :create, params: { character_features::builder::character_builder: invalid_attributes }
        }.not_to change(CharacterFeatures::builder::characterBuilder, :count)
      end
    end
  end





























end