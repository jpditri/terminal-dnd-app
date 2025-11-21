# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/world_lore_entrieseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:world_lore_entries) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:world_lore_entries)
      get world_lore_entrieseses_url
      expect(response).to be_successful
    end
  end
end