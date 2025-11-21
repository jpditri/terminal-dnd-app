# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campaigns::Campaigns::bulkOperationsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaigns::bulk_operations) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:campaigns::bulk_operations)
      get :index
      expect(response).to be_successful
    end
  end









end