# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SharedContentsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:shared_contents) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:shared_contents)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      shared_contents = create(:shared_contents)
      get :show, params: { id: shared_contents.to_param }
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
      it 'creates a new SharedContents' do
        expect {
          post :create, params: { shared_contents: valid_attributes }
        }.to change(SharedContents, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new SharedContents' do
        expect {
          post :create, params: { shared_contents: invalid_attributes }
        }.not_to change(SharedContents, :count)
      end
    end
  end


  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested shared_contents' do
        shared_contents = create(:shared_contents)
        put :update, params: { id: shared_contents.to_param, shared_contents: valid_attributes }
        shared_contents.reload
        expect(response).to redirect_to(shared_contents)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested shared_contents' do
      shared_contents = create(:shared_contents)
      expect {
        delete :destroy, params: { id: shared_contents.to_param }
      }.to change(SharedContents, :count).by(-1)
    end
  end





end