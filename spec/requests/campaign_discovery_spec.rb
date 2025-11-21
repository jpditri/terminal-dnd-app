# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/campaign_discoverieses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_discovery) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:campaign_discovery)
      get campaign_discoverieses_url
      expect(response).to be_successful
    end
  end
end