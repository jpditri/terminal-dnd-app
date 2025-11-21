# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/spell_filter_presetseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:spell_filter_presets) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:spell_filter_presets)
      get spell_filter_presetseses_url
      expect(response).to be_successful
    end
  end
end