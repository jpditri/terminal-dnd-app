# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EncounterMonstersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:encounter_monsters) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:encounter_monsters)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      encounter_monsters = create(:encounter_monsters)
      get :show, params: { id: encounter_monsters.to_param }
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
      it 'creates a new EncounterMonsters' do
        expect {
          post :create, params: { encounter_monsters: valid_attributes }
        }.to change(EncounterMonsters, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new EncounterMonsters' do
        expect {
          post :create, params: { encounter_monsters: invalid_attributes }
        }.not_to change(EncounterMonsters, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested encounter_monsters' do
        encounter_monsters = create(:encounter_monsters)
        put :update, params: { id: encounter_monsters.to_param, encounter_monsters: valid_attributes }
        encounter_monsters.reload
        expect(response).to redirect_to(encounter_monsters)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested encounter_monsters' do
      encounter_monsters = create(:encounter_monsters)
      expect {
        delete :destroy, params: { id: encounter_monsters.to_param }
      }.to change(EncounterMonsters, :count).by(-1)
    end
  end



end