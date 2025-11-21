# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/campaign_metricseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_metrics) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:campaign_metrics)
      get campaign_metricseses_url
      expect(response).to be_successful
    end
  end
end