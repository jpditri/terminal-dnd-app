# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_items) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:character_items)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      character_items = create(:character_items)
      get :show, params: { id: character_items.to_param }
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
      it 'creates a new CharacterItems' do
        expect {
          post :create, params: { character_items: valid_attributes }
        }.to change(CharacterItems, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CharacterItems' do
        expect {
          post :create, params: { character_items: invalid_attributes }
        }.not_to change(CharacterItems, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested character_items' do
        character_items = create(:character_items)
        put :update, params: { id: character_items.to_param, character_items: valid_attributes }
        character_items.reload
        expect(response).to redirect_to(character_items)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested character_items' do
      character_items = create(:character_items)
      expect {
        delete :destroy, params: { id: character_items.to_param }
      }.to change(CharacterItems, :count).by(-1)
    end
  end








end