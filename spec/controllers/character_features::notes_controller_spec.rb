# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::CharacterFeatures::notesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::notes) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:character_features::notes)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new CharacterFeatures::notes' do
        expect {
          post :create, params: { character_features::notes: valid_attributes }
        }.to change(CharacterFeatures::notes, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CharacterFeatures::notes' do
        expect {
          post :create, params: { character_features::notes: invalid_attributes }
        }.not_to change(CharacterFeatures::notes, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested character_features::notes' do
        character_features::notes = create(:character_features::notes)
        put :update, params: { id: character_features::notes.to_param, character_features::notes: valid_attributes }
        character_features::notes.reload
        expect(response).to redirect_to(character_features::notes)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested character_features::notes' do
      character_features::notes = create(:character_features::notes)
      expect {
        delete :destroy, params: { id: character_features::notes.to_param }
      }.to change(CharacterFeatures::notes, :count).by(-1)
    end
  end










end