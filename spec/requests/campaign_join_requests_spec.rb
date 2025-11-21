# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/campaign_join_requestseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_join_requests) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:campaign_join_requests)
      get campaign_join_requestseses_url
      expect(response).to be_successful
    end
  end
end