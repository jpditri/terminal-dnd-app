# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/user_blockseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:user_blocks) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:user_blocks)
      get user_blockseses_url
      expect(response).to be_successful
    end
  end
end