# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaigns) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:campaigns)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      campaigns = create(:campaigns)
      get :show, params: { id: campaigns.to_param }
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
      it 'creates a new Campaigns' do
        expect {
          post :create, params: { campaigns: valid_attributes }
        }.to change(Campaigns, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Campaigns' do
        expect {
          post :create, params: { campaigns: invalid_attributes }
        }.not_to change(Campaigns, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested campaigns' do
        campaigns = create(:campaigns)
        put :update, params: { id: campaigns.to_param, campaigns: valid_attributes }
        campaigns.reload
        expect(response).to redirect_to(campaigns)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested campaigns' do
      campaigns = create(:campaigns)
      expect {
        delete :destroy, params: { id: campaigns.to_param }
      }.to change(Campaigns, :count).by(-1)
    end
  end



















end