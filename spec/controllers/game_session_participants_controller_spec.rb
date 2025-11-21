# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameSessionParticipantsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:game_session_participants) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:game_session_participants)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      game_session_participants = create(:game_session_participants)
      get :show, params: { id: game_session_participants.to_param }
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
      it 'creates a new GameSessionParticipants' do
        expect {
          post :create, params: { game_session_participants: valid_attributes }
        }.to change(GameSessionParticipants, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new GameSessionParticipants' do
        expect {
          post :create, params: { game_session_participants: invalid_attributes }
        }.not_to change(GameSessionParticipants, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested game_session_participants' do
        game_session_participants = create(:game_session_participants)
        put :update, params: { id: game_session_participants.to_param, game_session_participants: valid_attributes }
        game_session_participants.reload
        expect(response).to redirect_to(game_session_participants)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested game_session_participants' do
      game_session_participants = create(:game_session_participants)
      expect {
        delete :destroy, params: { id: game_session_participants.to_param }
      }.to change(GameSessionParticipants, :count).by(-1)
    end
  end








end