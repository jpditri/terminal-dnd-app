# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/ai_dm_suggestionseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:ai_dm_suggestions) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:ai_dm_suggestions)
      get ai_dm_suggestionseses_url
      expect(response).to be_successful
    end
  end
end