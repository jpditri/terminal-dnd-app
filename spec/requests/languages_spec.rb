# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/languageseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:languages) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:languages)
      get languageseses_url
      expect(response).to be_successful
    end
  end
end