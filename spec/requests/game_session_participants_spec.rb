# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/game_session_participantseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:game_session_participants) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:game_session_participants)
      get game_session_participantseses_url
      expect(response).to be_successful
    end
  end
end