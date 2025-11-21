# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/campaign_ratingseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_ratings) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:campaign_ratings)
      get campaign_ratingseses_url
      expect(response).to be_successful
    end
  end
end