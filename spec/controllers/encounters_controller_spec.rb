# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EncountersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:encounters) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:encounters)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      encounters = create(:encounters)
      get :show, params: { id: encounters.to_param }
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
      it 'creates a new Encounters' do
        expect {
          post :create, params: { encounters: valid_attributes }
        }.to change(Encounters, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Encounters' do
        expect {
          post :create, params: { encounters: invalid_attributes }
        }.not_to change(Encounters, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested encounters' do
        encounters = create(:encounters)
        put :update, params: { id: encounters.to_param, encounters: valid_attributes }
        encounters.reload
        expect(response).to redirect_to(encounters)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested encounters' do
      encounters = create(:encounters)
      expect {
        delete :destroy, params: { id: encounters.to_param }
      }.to change(Encounters, :count).by(-1)
    end
  end



end