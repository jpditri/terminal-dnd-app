# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/character_features::progression::progressionseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::progression::progressions) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:character_features::progression::progressions)
      get character_features::progression::progressionseses_url
      expect(response).to be_successful
    end
  end
end