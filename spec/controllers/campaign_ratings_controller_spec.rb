# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignRatingsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_ratings) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new CampaignRatings' do
        expect {
          post :create, params: { campaign_ratings: valid_attributes }
        }.to change(CampaignRatings, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CampaignRatings' do
        expect {
          post :create, params: { campaign_ratings: invalid_attributes }
        }.not_to change(CampaignRatings, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested campaign_ratings' do
        campaign_ratings = create(:campaign_ratings)
        put :update, params: { id: campaign_ratings.to_param, campaign_ratings: valid_attributes }
        campaign_ratings.reload
        expect(response).to redirect_to(campaign_ratings)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested campaign_ratings' do
      campaign_ratings = create(:campaign_ratings)
      expect {
        delete :destroy, params: { id: campaign_ratings.to_param }
      }.to change(CampaignRatings, :count).by(-1)
    end
  end




end