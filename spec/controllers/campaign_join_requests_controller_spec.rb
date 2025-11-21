# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignJoinRequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_join_requests) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:campaign_join_requests)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new CampaignJoinRequests' do
        expect {
          post :create, params: { campaign_join_requests: valid_attributes }
        }.to change(CampaignJoinRequests, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CampaignJoinRequests' do
        expect {
          post :create, params: { campaign_join_requests: invalid_attributes }
        }.not_to change(CampaignJoinRequests, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested campaign_join_requests' do
      campaign_join_requests = create(:campaign_join_requests)
      expect {
        delete :destroy, params: { id: campaign_join_requests.to_param }
      }.to change(CampaignJoinRequests, :count).by(-1)
    end
  end






end