# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/tokenseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:tokens) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:tokens)
      get tokenseses_url
      expect(response).to be_successful
    end
  end
end