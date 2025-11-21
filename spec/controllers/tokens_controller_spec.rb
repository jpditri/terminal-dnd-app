# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:tokens) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:tokens)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      tokens = create(:tokens)
      get :show, params: { id: tokens.to_param }
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
      it 'creates a new Tokens' do
        expect {
          post :create, params: { tokens: valid_attributes }
        }.to change(Tokens, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Tokens' do
        expect {
          post :create, params: { tokens: invalid_attributes }
        }.not_to change(Tokens, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested tokens' do
        tokens = create(:tokens)
        put :update, params: { id: tokens.to_param, tokens: valid_attributes }
        tokens.reload
        expect(response).to redirect_to(tokens)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested tokens' do
      tokens = create(:tokens)
      expect {
        delete :destroy, params: { id: tokens.to_param }
      }.to change(Tokens, :count).by(-1)
    end
  end




end