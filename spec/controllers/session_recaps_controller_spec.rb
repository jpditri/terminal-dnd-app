# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionRecapsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:session_recaps) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:session_recaps)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      session_recaps = create(:session_recaps)
      get :show, params: { id: session_recaps.to_param }
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
      it 'creates a new SessionRecaps' do
        expect {
          post :create, params: { session_recaps: valid_attributes }
        }.to change(SessionRecaps, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new SessionRecaps' do
        expect {
          post :create, params: { session_recaps: invalid_attributes }
        }.not_to change(SessionRecaps, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested session_recaps' do
        session_recaps = create(:session_recaps)
        put :update, params: { id: session_recaps.to_param, session_recaps: valid_attributes }
        session_recaps.reload
        expect(response).to redirect_to(session_recaps)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested session_recaps' do
      session_recaps = create(:session_recaps)
      expect {
        delete :destroy, params: { id: session_recaps.to_param }
      }.to change(SessionRecaps, :count).by(-1)
    end
  end



end