# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/settings::themeses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:settings::them) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:settings::them)
      get settings::themeses_url
      expect(response).to be_successful
    end
  end
end