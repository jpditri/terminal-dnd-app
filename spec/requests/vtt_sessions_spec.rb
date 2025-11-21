# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/vtt_sessionseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:vtt_sessions) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:vtt_sessions)
      get vtt_sessionseses_url
      expect(response).to be_successful
    end
  end
end