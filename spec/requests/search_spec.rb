# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/searcheses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:search) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:search)
      get searcheses_url
      expect(response).to be_successful
    end
  end
end