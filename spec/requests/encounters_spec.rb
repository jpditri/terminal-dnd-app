# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/encounterseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:encounters) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:encounters)
      get encounterseses_url
      expect(response).to be_successful
    end
  end
end