# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/homebrew::magic_itemseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:homebrew::magic_items) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:homebrew::magic_items)
      get homebrew::magic_itemseses_url
      expect(response).to be_successful
    end
  end
end