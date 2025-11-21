# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:health) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:health)
      get :index
      expect(response).to be_successful
    end
  end


end