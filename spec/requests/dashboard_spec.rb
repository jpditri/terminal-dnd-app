# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/dashboardses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:dashboard) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:dashboard)
      get dashboardses_url
      expect(response).to be_successful
    end
  end
end