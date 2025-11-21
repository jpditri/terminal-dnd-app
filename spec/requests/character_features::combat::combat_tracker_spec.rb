# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/character_features::combat::combat_trackerses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::combat::combat_tracker) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:character_features::combat::combat_tracker)
      get character_features::combat::combat_trackerses_url
      expect(response).to be_successful
    end
  end
end