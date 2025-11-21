# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/solo_game_stateseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:solo_game_states) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:solo_game_states)
      get solo_game_stateseses_url
      expect(response).to be_successful
    end
  end
end