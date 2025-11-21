# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiConversationsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:ai_conversations) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:ai_conversations)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      ai_conversations = create(:ai_conversations)
      get :show, params: { id: ai_conversations.to_param }
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
      it 'creates a new AiConversations' do
        expect {
          post :create, params: { ai_conversations: valid_attributes }
        }.to change(AiConversations, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new AiConversations' do
        expect {
          post :create, params: { ai_conversations: invalid_attributes }
        }.not_to change(AiConversations, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested ai_conversations' do
        ai_conversations = create(:ai_conversations)
        put :update, params: { id: ai_conversations.to_param, ai_conversations: valid_attributes }
        ai_conversations.reload
        expect(response).to redirect_to(ai_conversations)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested ai_conversations' do
      ai_conversations = create(:ai_conversations)
      expect {
        delete :destroy, params: { id: ai_conversations.to_param }
      }.to change(AiConversations, :count).by(-1)
    end
  end



end