# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MapsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:maps) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:maps)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      maps = create(:maps)
      get :show, params: { id: maps.to_param }
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
      it 'creates a new Maps' do
        expect {
          post :create, params: { maps: valid_attributes }
        }.to change(Maps, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Maps' do
        expect {
          post :create, params: { maps: invalid_attributes }
        }.not_to change(Maps, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested maps' do
        maps = create(:maps)
        put :update, params: { id: maps.to_param, maps: valid_attributes }
        maps.reload
        expect(response).to redirect_to(maps)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested maps' do
      maps = create(:maps)
      expect {
        delete :destroy, params: { id: maps.to_param }
      }.to change(Maps, :count).by(-1)
    end
  end





end