# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/character_features::sheet::character_sheetseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::sheet::character_sheets) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:character_features::sheet::character_sheets)
      get character_features::sheet::character_sheetseses_url
      expect(response).to be_successful
    end
  end
end