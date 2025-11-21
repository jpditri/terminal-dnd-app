# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CombatsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:combats) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:combats)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      combats = create(:combats)
      get :show, params: { id: combats.to_param }
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
      it 'creates a new Combats' do
        expect {
          post :create, params: { combats: valid_attributes }
        }.to change(Combats, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Combats' do
        expect {
          post :create, params: { combats: invalid_attributes }
        }.not_to change(Combats, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested combats' do
        combats = create(:combats)
        put :update, params: { id: combats.to_param, combats: valid_attributes }
        combats.reload
        expect(response).to redirect_to(combats)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested combats' do
      combats = create(:combats)
      expect {
        delete :destroy, params: { id: combats.to_param }
      }.to change(Combats, :count).by(-1)
    end
  end


end