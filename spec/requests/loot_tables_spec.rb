# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/loot_tableseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:loot_tables) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:loot_tables)
      get loot_tableseses_url
      expect(response).to be_successful
    end
  end
end