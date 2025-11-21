# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignTemplatesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_templates) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:campaign_templates)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      campaign_templates = create(:campaign_templates)
      get :show, params: { id: campaign_templates.to_param }
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
      it 'creates a new CampaignTemplates' do
        expect {
          post :create, params: { campaign_templates: valid_attributes }
        }.to change(CampaignTemplates, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CampaignTemplates' do
        expect {
          post :create, params: { campaign_templates: invalid_attributes }
        }.not_to change(CampaignTemplates, :count)
      end
    end
  end


  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested campaign_templates' do
        campaign_templates = create(:campaign_templates)
        put :update, params: { id: campaign_templates.to_param, campaign_templates: valid_attributes }
        campaign_templates.reload
        expect(response).to redirect_to(campaign_templates)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested campaign_templates' do
      campaign_templates = create(:campaign_templates)
      expect {
        delete :destroy, params: { id: campaign_templates.to_param }
      }.to change(CampaignTemplates, :count).by(-1)
    end
  end





end