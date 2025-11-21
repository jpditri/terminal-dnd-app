# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/friend_requestseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:friend_requests) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:friend_requests)
      get friend_requestseses_url
      expect(response).to be_successful
    end
  end
end