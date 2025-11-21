# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/encounter_monsterseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:encounter_monsters) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:encounter_monsters)
      get encounter_monsterseses_url
      expect(response).to be_successful
    end
  end
end