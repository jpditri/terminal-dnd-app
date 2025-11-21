# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:search) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:search)
      get :index
      expect(response).to be_successful
    end
  end



end