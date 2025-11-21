# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/homebrew::raceseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:homebrew::races) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:homebrew::races)
      get homebrew::raceseses_url
      expect(response).to be_successful
    end
  end
end