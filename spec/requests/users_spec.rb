# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/userseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:users) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:users)
      get userseses_url
      expect(response).to be_successful
    end
  end
end