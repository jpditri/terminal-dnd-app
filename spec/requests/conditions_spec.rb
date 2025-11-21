# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/conditionseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:conditions) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:conditions)
      get conditionseses_url
      expect(response).to be_successful
    end
  end
end