# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeatures::AiAssistant::CharacterFeatures::aiAssistant::aiAssistantController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::ai_assistant::ai_assistant) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      character_features::ai_assistant::ai_assistant = create(:character_features::ai_assistant::ai_assistant)
      get :show, params: { id: character_features::ai_assistant::ai_assistant.to_param }
      expect(response).to be_successful
    end
  end
























end