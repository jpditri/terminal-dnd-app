# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorldsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:worlds) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:worlds)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      worlds = create(:worlds)
      get :show, params: { id: worlds.to_param }
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
      it 'creates a new Worlds' do
        expect {
          post :create, params: { worlds: valid_attributes }
        }.to change(Worlds, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Worlds' do
        expect {
          post :create, params: { worlds: invalid_attributes }
        }.not_to change(Worlds, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested worlds' do
        worlds = create(:worlds)
        put :update, params: { id: worlds.to_param, worlds: valid_attributes }
        worlds.reload
        expect(response).to redirect_to(worlds)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested worlds' do
      worlds = create(:worlds)
      expect {
        delete :destroy, params: { id: worlds.to_param }
      }.to change(Worlds, :count).by(-1)
    end
  end








end