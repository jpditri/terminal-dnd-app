# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignMetricsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_metrics) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:campaign_metrics)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      campaign_metrics = create(:campaign_metrics)
      get :show, params: { id: campaign_metrics.to_param }
      expect(response).to be_successful
    end
  end




end