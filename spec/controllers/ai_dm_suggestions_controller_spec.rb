# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiDmSuggestionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:ai_dm_suggestions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:ai_dm_suggestions)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new AiDmSuggestions' do
        expect {
          post :create, params: { ai_dm_suggestions: valid_attributes }
        }.to change(AiDmSuggestions, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new AiDmSuggestions' do
        expect {
          post :create, params: { ai_dm_suggestions: invalid_attributes }
        }.not_to change(AiDmSuggestions, :count)
      end
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      ai_dm_suggestions = create(:ai_dm_suggestions)
      get :show, params: { id: ai_dm_suggestions.to_param }
      expect(response).to be_successful
    end
  end









end