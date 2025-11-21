# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SoloGameStatesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:solo_game_states) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:solo_game_states)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      solo_game_states = create(:solo_game_states)
      get :show, params: { id: solo_game_states.to_param }
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
      it 'creates a new SoloGameStates' do
        expect {
          post :create, params: { solo_game_states: valid_attributes }
        }.to change(SoloGameStates, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new SoloGameStates' do
        expect {
          post :create, params: { solo_game_states: invalid_attributes }
        }.not_to change(SoloGameStates, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested solo_game_states' do
        solo_game_states = create(:solo_game_states)
        put :update, params: { id: solo_game_states.to_param, solo_game_states: valid_attributes }
        solo_game_states.reload
        expect(response).to redirect_to(solo_game_states)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested solo_game_states' do
      solo_game_states = create(:solo_game_states)
      expect {
        delete :destroy, params: { id: solo_game_states.to_param }
      }.to change(SoloGameStates, :count).by(-1)
    end
  end








end