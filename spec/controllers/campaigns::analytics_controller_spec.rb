# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campaigns::Campaigns::analyticsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaigns::analytics) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:campaigns::analytics)
      get :index
      expect(response).to be_successful
    end
  end




end