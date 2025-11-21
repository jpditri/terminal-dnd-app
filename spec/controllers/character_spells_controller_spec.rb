# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterSpellsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_spells) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:character_spells)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      character_spells = create(:character_spells)
      get :show, params: { id: character_spells.to_param }
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
      it 'creates a new CharacterSpells' do
        expect {
          post :create, params: { character_spells: valid_attributes }
        }.to change(CharacterSpells, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CharacterSpells' do
        expect {
          post :create, params: { character_spells: invalid_attributes }
        }.not_to change(CharacterSpells, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested character_spells' do
        character_spells = create(:character_spells)
        put :update, params: { id: character_spells.to_param, character_spells: valid_attributes }
        character_spells.reload
        expect(response).to redirect_to(character_spells)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested character_spells' do
      character_spells = create(:character_spells)
      expect {
        delete :destroy, params: { id: character_spells.to_param }
      }.to change(CharacterSpells, :count).by(-1)
    end
  end








end