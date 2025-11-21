# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FactionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:factions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:factions)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      factions = create(:factions)
      get :show, params: { id: factions.to_param }
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
      it 'creates a new Factions' do
        expect {
          post :create, params: { factions: valid_attributes }
        }.to change(Factions, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Factions' do
        expect {
          post :create, params: { factions: invalid_attributes }
        }.not_to change(Factions, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested factions' do
        factions = create(:factions)
        put :update, params: { id: factions.to_param, factions: valid_attributes }
        factions.reload
        expect(response).to redirect_to(factions)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested factions' do
      factions = create(:factions)
      expect {
        delete :destroy, params: { id: factions.to_param }
      }.to change(Factions, :count).by(-1)
    end
  end




end