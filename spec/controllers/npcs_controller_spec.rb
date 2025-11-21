# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NpcsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:npcs) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:npcs)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      npcs = create(:npcs)
      get :show, params: { id: npcs.to_param }
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
      it 'creates a new Npcs' do
        expect {
          post :create, params: { npcs: valid_attributes }
        }.to change(Npcs, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Npcs' do
        expect {
          post :create, params: { npcs: invalid_attributes }
        }.not_to change(Npcs, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested npcs' do
        npcs = create(:npcs)
        put :update, params: { id: npcs.to_param, npcs: valid_attributes }
        npcs.reload
        expect(response).to redirect_to(npcs)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested npcs' do
      npcs = create(:npcs)
      expect {
        delete :destroy, params: { id: npcs.to_param }
      }.to change(Npcs, :count).by(-1)
    end
  end









end