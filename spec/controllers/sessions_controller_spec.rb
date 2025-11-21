# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:sessions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Sessions' do
        expect {
          post :create, params: { sessions: valid_attributes }
        }.to change(Sessions, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Sessions' do
        expect {
          post :create, params: { sessions: invalid_attributes }
        }.not_to change(Sessions, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested sessions' do
      sessions = create(:sessions)
      expect {
        delete :destroy, params: { id: sessions.to_param }
      }.to change(Sessions, :count).by(-1)
    end
  end




end