# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VttSessionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:vtt_sessions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      vtt_sessions = create(:vtt_sessions)
      get :show, params: { id: vtt_sessions.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new VttSessions' do
        expect {
          post :create, params: { vtt_sessions: valid_attributes }
        }.to change(VttSessions, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new VttSessions' do
        expect {
          post :create, params: { vtt_sessions: invalid_attributes }
        }.not_to change(VttSessions, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested vtt_sessions' do
      vtt_sessions = create(:vtt_sessions)
      expect {
        delete :destroy, params: { id: vtt_sessions.to_param }
      }.to change(VttSessions, :count).by(-1)
    end
  end


end