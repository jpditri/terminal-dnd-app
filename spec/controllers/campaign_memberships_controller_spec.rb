# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignMembershipsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_memberships) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:campaign_memberships)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      campaign_memberships = create(:campaign_memberships)
      get :show, params: { id: campaign_memberships.to_param }
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
      it 'creates a new CampaignMemberships' do
        expect {
          post :create, params: { campaign_memberships: valid_attributes }
        }.to change(CampaignMemberships, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CampaignMemberships' do
        expect {
          post :create, params: { campaign_memberships: invalid_attributes }
        }.not_to change(CampaignMemberships, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested campaign_memberships' do
        campaign_memberships = create(:campaign_memberships)
        put :update, params: { id: campaign_memberships.to_param, campaign_memberships: valid_attributes }
        campaign_memberships.reload
        expect(response).to redirect_to(campaign_memberships)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested campaign_memberships' do
      campaign_memberships = create(:campaign_memberships)
      expect {
        delete :destroy, params: { id: campaign_memberships.to_param }
      }.to change(CampaignMemberships, :count).by(-1)
    end
  end








end