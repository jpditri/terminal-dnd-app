# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiDmAssistantsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:ai_dm_assistants) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      ai_dm_assistants = create(:ai_dm_assistants)
      get :show, params: { id: ai_dm_assistants.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new AiDmAssistants' do
        expect {
          post :create, params: { ai_dm_assistants: valid_attributes }
        }.to change(AiDmAssistants, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new AiDmAssistants' do
        expect {
          post :create, params: { ai_dm_assistants: invalid_attributes }
        }.not_to change(AiDmAssistants, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested ai_dm_assistants' do
        ai_dm_assistants = create(:ai_dm_assistants)
        put :update, params: { id: ai_dm_assistants.to_param, ai_dm_assistants: valid_attributes }
        ai_dm_assistants.reload
        expect(response).to redirect_to(ai_dm_assistants)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested ai_dm_assistants' do
      ai_dm_assistants = create(:ai_dm_assistants)
      expect {
        delete :destroy, params: { id: ai_dm_assistants.to_param }
      }.to change(AiDmAssistants, :count).by(-1)
    end
  end









end