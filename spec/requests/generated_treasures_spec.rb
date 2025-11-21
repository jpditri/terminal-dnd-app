# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/generated_treasureseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:generated_treasures) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:generated_treasures)
      get generated_treasureseses_url
      expect(response).to be_successful
    end
  end
end