# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterNotesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_notes) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:character_notes)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      character_notes = create(:character_notes)
      get :show, params: { id: character_notes.to_param }
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
      it 'creates a new CharacterNotes' do
        expect {
          post :create, params: { character_notes: valid_attributes }
        }.to change(CharacterNotes, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CharacterNotes' do
        expect {
          post :create, params: { character_notes: invalid_attributes }
        }.not_to change(CharacterNotes, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested character_notes' do
        character_notes = create(:character_notes)
        put :update, params: { id: character_notes.to_param, character_notes: valid_attributes }
        character_notes.reload
        expect(response).to redirect_to(character_notes)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested character_notes' do
      character_notes = create(:character_notes)
      expect {
        delete :destroy, params: { id: character_notes.to_param }
      }.to change(CharacterNotes, :count).by(-1)
    end
  end








end