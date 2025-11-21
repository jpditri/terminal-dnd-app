# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:users) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:users)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      users = create(:users)
      get :show, params: { id: users.to_param }
      expect(response).to be_successful
    end
  end


  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Users' do
        expect {
          post :create, params: { users: valid_attributes }
        }.to change(Users, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Users' do
        expect {
          post :create, params: { users: invalid_attributes }
        }.not_to change(Users, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested users' do
        users = create(:users)
        put :update, params: { id: users.to_param, users: valid_attributes }
        users.reload
        expect(response).to redirect_to(users)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested users' do
      users = create(:users)
      expect {
        delete :destroy, params: { id: users.to_param }
      }.to change(Users, :count).by(-1)
    end
  end








end