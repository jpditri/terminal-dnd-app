# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/ai_messageseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:ai_messages) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:ai_messages)
      get ai_messageseses_url
      expect(response).to be_successful
    end
  end
end