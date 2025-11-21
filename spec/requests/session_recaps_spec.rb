# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/session_recapseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:session_recaps) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:session_recaps)
      get session_recapseses_url
      expect(response).to be_successful
    end
  end
end