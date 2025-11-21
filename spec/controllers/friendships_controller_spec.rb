# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendshipsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:friendships) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:friendships)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested friendships' do
      friendships = create(:friendships)
      expect {
        delete :destroy, params: { id: friendships.to_param }
      }.to change(Friendships, :count).by(-1)
    end
  end


end