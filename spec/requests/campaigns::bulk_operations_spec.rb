# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/campaigns::bulk_operationseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaigns::bulk_operations) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:campaigns::bulk_operations)
      get campaigns::bulk_operationseses_url
      expect(response).to be_successful
    end
  end
end