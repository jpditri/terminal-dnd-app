# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/monster_abilitieseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:monster_abilities) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:monster_abilities)
      get monster_abilitieseses_url
      expect(response).to be_successful
    end
  end
end