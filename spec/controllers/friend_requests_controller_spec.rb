# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendRequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:friend_requests) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:friend_requests)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      friend_requests = create(:friend_requests)
      get :show, params: { id: friend_requests.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new FriendRequests' do
        expect {
          post :create, params: { friend_requests: valid_attributes }
        }.to change(FriendRequests, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new FriendRequests' do
        expect {
          post :create, params: { friend_requests: invalid_attributes }
        }.not_to change(FriendRequests, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested friend_requests' do
      friend_requests = create(:friend_requests)
      expect {
        delete :destroy, params: { id: friend_requests.to_param }
      }.to change(FriendRequests, :count).by(-1)
    end
  end





end