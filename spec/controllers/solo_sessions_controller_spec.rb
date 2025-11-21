# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SoloSessionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:solo_sessions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:solo_sessions)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      solo_sessions = create(:solo_sessions)
      get :show, params: { id: solo_sessions.to_param }
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
      it 'creates a new SoloSessions' do
        expect {
          post :create, params: { solo_sessions: valid_attributes }
        }.to change(SoloSessions, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new SoloSessions' do
        expect {
          post :create, params: { solo_sessions: invalid_attributes }
        }.not_to change(SoloSessions, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested solo_sessions' do
        solo_sessions = create(:solo_sessions)
        put :update, params: { id: solo_sessions.to_param, solo_sessions: valid_attributes }
        solo_sessions.reload
        expect(response).to redirect_to(solo_sessions)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested solo_sessions' do
      solo_sessions = create(:solo_sessions)
      expect {
        delete :destroy, params: { id: solo_sessions.to_param }
      }.to change(SoloSessions, :count).by(-1)
    end
  end









end