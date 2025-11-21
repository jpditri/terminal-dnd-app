# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/homebrew_itemseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:homebrew_items) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:homebrew_items)
      get homebrew_itemseses_url
      expect(response).to be_successful
    end
  end
end