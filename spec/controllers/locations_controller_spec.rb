# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:locations) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:locations)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      locations = create(:locations)
      get :show, params: { id: locations.to_param }
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
      it 'creates a new Locations' do
        expect {
          post :create, params: { locations: valid_attributes }
        }.to change(Locations, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Locations' do
        expect {
          post :create, params: { locations: invalid_attributes }
        }.not_to change(Locations, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested locations' do
        locations = create(:locations)
        put :update, params: { id: locations.to_param, locations: valid_attributes }
        locations.reload
        expect(response).to redirect_to(locations)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested locations' do
      locations = create(:locations)
      expect {
        delete :destroy, params: { id: locations.to_param }
      }.to change(Locations, :count).by(-1)
    end
  end




end