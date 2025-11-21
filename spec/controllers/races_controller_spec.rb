# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RacesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:races) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:races)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      races = create(:races)
      get :show, params: { id: races.to_param }
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
      it 'creates a new Races' do
        expect {
          post :create, params: { races: valid_attributes }
        }.to change(Races, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Races' do
        expect {
          post :create, params: { races: invalid_attributes }
        }.not_to change(Races, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested races' do
        races = create(:races)
        put :update, params: { id: races.to_param, races: valid_attributes }
        races.reload
        expect(response).to redirect_to(races)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested races' do
      races = create(:races)
      expect {
        delete :destroy, params: { id: races.to_param }
      }.to change(Races, :count).by(-1)
    end
  end








end