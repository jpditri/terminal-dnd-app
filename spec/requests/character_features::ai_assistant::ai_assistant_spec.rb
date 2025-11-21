# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/character_features::ai_assistant::ai_assistantses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::ai_assistant::ai_assistant) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:character_features::ai_assistant::ai_assistant)
      get character_features::ai_assistant::ai_assistantses_url
      expect(response).to be_successful
    end
  end
end