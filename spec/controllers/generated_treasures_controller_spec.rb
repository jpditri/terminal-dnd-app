# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeneratedTreasuresController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:generated_treasures) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:generated_treasures)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      generated_treasures = create(:generated_treasures)
      get :show, params: { id: generated_treasures.to_param }
      expect(response).to be_successful
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested generated_treasures' do
      generated_treasures = create(:generated_treasures)
      expect {
        delete :destroy, params: { id: generated_treasures.to_param }
      }.to change(GeneratedTreasures, :count).by(-1)
    end
  end


end