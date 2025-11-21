# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/solo_sessionseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:solo_sessions) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:solo_sessions)
      get solo_sessionseses_url
      expect(response).to be_successful
    end
  end
end