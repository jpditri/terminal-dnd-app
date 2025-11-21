# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/game_sessionseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:game_sessions) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:game_sessions)
      get game_sessionseses_url
      expect(response).to be_successful
    end
  end
end