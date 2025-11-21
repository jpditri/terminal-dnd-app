# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::CharacterFeatures::templatesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::templates) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:character_features::templates)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::templates = create(:character_features::templates)
      get :show, params: { id: character_features::templates.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new CharacterFeatures::templates' do
        expect {
          post :create, params: { character_features::templates: valid_attributes }
        }.to change(CharacterFeatures::templates, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CharacterFeatures::templates' do
        expect {
          post :create, params: { character_features::templates: invalid_attributes }
        }.not_to change(CharacterFeatures::templates, :count)
      end
    end
  end


  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested character_features::templates' do
        character_features::templates = create(:character_features::templates)
        put :update, params: { id: character_features::templates.to_param, character_features::templates: valid_attributes }
        character_features::templates.reload
        expect(response).to redirect_to(character_features::templates)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested character_features::templates' do
      character_features::templates = create(:character_features::templates)
      expect {
        delete :destroy, params: { id: character_features::templates.to_param }
      }.to change(CharacterFeatures::templates, :count).by(-1)
    end
  end












end