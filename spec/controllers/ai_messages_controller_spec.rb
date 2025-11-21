# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiMessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:ai_messages) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:ai_messages)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      ai_messages = create(:ai_messages)
      get :show, params: { id: ai_messages.to_param }
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
      it 'creates a new AiMessages' do
        expect {
          post :create, params: { ai_messages: valid_attributes }
        }.to change(AiMessages, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new AiMessages' do
        expect {
          post :create, params: { ai_messages: invalid_attributes }
        }.not_to change(AiMessages, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested ai_messages' do
        ai_messages = create(:ai_messages)
        put :update, params: { id: ai_messages.to_param, ai_messages: valid_attributes }
        ai_messages.reload
        expect(response).to redirect_to(ai_messages)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested ai_messages' do
      ai_messages = create(:ai_messages)
      expect {
        delete :destroy, params: { id: ai_messages.to_param }
      }.to change(AiMessages, :count).by(-1)
    end
  end



end