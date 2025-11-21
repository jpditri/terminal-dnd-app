# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/character_spellseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_spells) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:character_spells)
      get character_spellseses_url
      expect(response).to be_successful
    end
  end
end