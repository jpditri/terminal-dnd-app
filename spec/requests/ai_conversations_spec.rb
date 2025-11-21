# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/ai_conversationseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:ai_conversations) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:ai_conversations)
      get ai_conversationseses_url
      expect(response).to be_successful
    end
  end
end