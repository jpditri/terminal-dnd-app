# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/campaign_membershipseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_memberships) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:campaign_memberships)
      get campaign_membershipseses_url
      expect(response).to be_successful
    end
  end
end