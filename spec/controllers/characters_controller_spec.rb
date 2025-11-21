# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharactersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:characters) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:characters)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      characters = create(:characters)
      get :show, params: { id: characters.to_param }
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
      it 'creates a new Characters' do
        expect {
          post :create, params: { characters: valid_attributes }
        }.to change(Characters, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Characters' do
        expect {
          post :create, params: { characters: invalid_attributes }
        }.not_to change(Characters, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested characters' do
        characters = create(:characters)
        put :update, params: { id: characters.to_param, characters: valid_attributes }
        characters.reload
        expect(response).to redirect_to(characters)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested characters' do
      characters = create(:characters)
      expect {
        delete :destroy, params: { id: characters.to_param }
      }.to change(Characters, :count).by(-1)
    end
  end













end