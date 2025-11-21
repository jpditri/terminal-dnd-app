# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestLogsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:quest_logs) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:quest_logs)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      quest_logs = create(:quest_logs)
      get :show, params: { id: quest_logs.to_param }
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
      it 'creates a new QuestLogs' do
        expect {
          post :create, params: { quest_logs: valid_attributes }
        }.to change(QuestLogs, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new QuestLogs' do
        expect {
          post :create, params: { quest_logs: invalid_attributes }
        }.not_to change(QuestLogs, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested quest_logs' do
        quest_logs = create(:quest_logs)
        put :update, params: { id: quest_logs.to_param, quest_logs: valid_attributes }
        quest_logs.reload
        expect(response).to redirect_to(quest_logs)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested quest_logs' do
      quest_logs = create(:quest_logs)
      expect {
        delete :destroy, params: { id: quest_logs.to_param }
      }.to change(QuestLogs, :count).by(-1)
    end
  end




end