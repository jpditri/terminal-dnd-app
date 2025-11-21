# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestObjectivesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:quest_objectives) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:quest_objectives)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      quest_objectives = create(:quest_objectives)
      get :show, params: { id: quest_objectives.to_param }
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
      it 'creates a new QuestObjectives' do
        expect {
          post :create, params: { quest_objectives: valid_attributes }
        }.to change(QuestObjectives, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new QuestObjectives' do
        expect {
          post :create, params: { quest_objectives: invalid_attributes }
        }.not_to change(QuestObjectives, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested quest_objectives' do
        quest_objectives = create(:quest_objectives)
        put :update, params: { id: quest_objectives.to_param, quest_objectives: valid_attributes }
        quest_objectives.reload
        expect(response).to redirect_to(quest_objectives)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested quest_objectives' do
      quest_objectives = create(:quest_objectives)
      expect {
        delete :destroy, params: { id: quest_objectives.to_param }
      }.to change(QuestObjectives, :count).by(-1)
    end
  end




end