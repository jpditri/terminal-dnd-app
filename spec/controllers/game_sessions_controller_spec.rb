# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameSessionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:game_sessions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:game_sessions)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      game_sessions = create(:game_sessions)
      get :show, params: { id: game_sessions.to_param }
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
      it 'creates a new GameSessions' do
        expect {
          post :create, params: { game_sessions: valid_attributes }
        }.to change(GameSessions, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new GameSessions' do
        expect {
          post :create, params: { game_sessions: invalid_attributes }
        }.not_to change(GameSessions, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested game_sessions' do
        game_sessions = create(:game_sessions)
        put :update, params: { id: game_sessions.to_param, game_sessions: valid_attributes }
        game_sessions.reload
        expect(response).to redirect_to(game_sessions)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested game_sessions' do
      game_sessions = create(:game_sessions)
      expect {
        delete :destroy, params: { id: game_sessions.to_param }
      }.to change(GameSessions, :count).by(-1)
    end
  end











end