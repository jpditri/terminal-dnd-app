# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/player_engagementseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:player_engagements) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:player_engagements)
      get player_engagementseses_url
      expect(response).to be_successful
    end
  end
end