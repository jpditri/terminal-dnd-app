# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/dice_rollseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:dice_rolls) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:dice_rolls)
      get dice_rollseses_url
      expect(response).to be_successful
    end
  end
end