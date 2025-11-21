# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/campaigns::questseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaigns::quests) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:campaigns::quests)
      get campaigns::questseses_url
      expect(response).to be_successful
    end
  end
end