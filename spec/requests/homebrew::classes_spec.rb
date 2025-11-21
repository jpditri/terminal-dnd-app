# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/homebrew::classeseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:homebrew::classes) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:homebrew::classes)
      get homebrew::classeseses_url
      expect(response).to be_successful
    end
  end
end