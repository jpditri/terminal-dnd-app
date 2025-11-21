# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/character_features::homebrew::homebrewseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::homebrew::homebrews) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:character_features::homebrew::homebrews)
      get character_features::homebrew::homebrewseses_url
      expect(response).to be_successful
    end
  end
end