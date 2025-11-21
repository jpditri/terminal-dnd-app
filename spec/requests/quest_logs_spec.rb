# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/quest_logseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:quest_logs) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:quest_logs)
      get quest_logseses_url
      expect(response).to be_successful
    end
  end
end