# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Homebrew::Homebrew::magicItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:homebrew::magic_items) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:homebrew::magic_items)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      homebrew::magic_items = create(:homebrew::magic_items)
      get :show, params: { id: homebrew::magic_items.to_param }
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
      it 'creates a new Homebrew::magicItems' do
        expect {
          post :create, params: { homebrew::magic_items: valid_attributes }
        }.to change(Homebrew::magicItems, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Homebrew::magicItems' do
        expect {
          post :create, params: { homebrew::magic_items: invalid_attributes }
        }.not_to change(Homebrew::magicItems, :count)
      end
    end
  end


  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested homebrew::magic_items' do
        homebrew::magic_items = create(:homebrew::magic_items)
        put :update, params: { id: homebrew::magic_items.to_param, homebrew::magic_items: valid_attributes }
        homebrew::magic_items.reload
        expect(response).to redirect_to(homebrew::magic_items)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested homebrew::magic_items' do
      homebrew::magic_items = create(:homebrew::magic_items)
      expect {
        delete :destroy, params: { id: homebrew::magic_items.to_param }
      }.to change(Homebrew::magicItems, :count).by(-1)
    end
  end





end