# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:items) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:items)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      items = create(:items)
      get :show, params: { id: items.to_param }
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
      it 'creates a new Items' do
        expect {
          post :create, params: { items: valid_attributes }
        }.to change(Items, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Items' do
        expect {
          post :create, params: { items: invalid_attributes }
        }.not_to change(Items, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested items' do
        items = create(:items)
        put :update, params: { id: items.to_param, items: valid_attributes }
        items.reload
        expect(response).to redirect_to(items)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested items' do
      items = create(:items)
      expect {
        delete :destroy, params: { id: items.to_param }
      }.to change(Items, :count).by(-1)
    end
  end








end