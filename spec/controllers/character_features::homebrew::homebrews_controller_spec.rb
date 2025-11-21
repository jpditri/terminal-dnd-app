# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::Homebrew::CharacterFeatures::homebrew::homebrewsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::homebrew::homebrews) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:character_features::homebrew::homebrews)
      get :index
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
      it 'creates a new CharacterFeatures::homebrew::homebrews' do
        expect {
          post :create, params: { character_features::homebrew::homebrews: valid_attributes }
        }.to change(CharacterFeatures::homebrew::homebrews, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CharacterFeatures::homebrew::homebrews' do
        expect {
          post :create, params: { character_features::homebrew::homebrews: invalid_attributes }
        }.not_to change(CharacterFeatures::homebrew::homebrews, :count)
      end
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::homebrew::homebrews = create(:character_features::homebrew::homebrews)
      get :show, params: { id: character_features::homebrew::homebrews.to_param }
      expect(response).to be_successful
    end
  end


  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested character_features::homebrew::homebrews' do
        character_features::homebrew::homebrews = create(:character_features::homebrew::homebrews)
        put :update, params: { id: character_features::homebrew::homebrews.to_param, character_features::homebrew::homebrews: valid_attributes }
        character_features::homebrew::homebrews.reload
        expect(response).to redirect_to(character_features::homebrew::homebrews)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested character_features::homebrew::homebrews' do
      character_features::homebrew::homebrews = create(:character_features::homebrew::homebrews)
      expect {
        delete :destroy, params: { id: character_features::homebrew::homebrews.to_param }
      }.to change(CharacterFeatures::homebrew::homebrews, :count).by(-1)
    end
  end












end