# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/homebrew::managementses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:homebrew::management) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:homebrew::management)
      get homebrew::managementses_url
      expect(response).to be_successful
    end
  end
end