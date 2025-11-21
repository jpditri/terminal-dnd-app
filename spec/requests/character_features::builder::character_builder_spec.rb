# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/character_features::builder::character_builderses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_features::builder::character_builder) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:character_features::builder::character_builder)
      get character_features::builder::character_builderses_url
      expect(response).to be_successful
    end
  end
end