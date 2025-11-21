# frozen_string_literal: true

class CampaignDiscoveryController < ApplicationController
  before_action :set_user

  def index
    @campaign_discoveries = policy_scope(CampaignDiscovery)
    @campaign_discoveries = @campaign_discoveries.search(params[:q]) if params[:q].present?
    @campaign_discoveries = @campaign_discoveries.page(params[:page]).per(20)
  end

  def show
    authorize @campaign_discovery
  end

  def set_user
    # TODO: Implement set_user
  end

  private

  def set_campaign_discovery
    @campaign_discovery = CampaignDiscovery.find(params[:id])
  end

  def campaign_discovery_params
    params.require(:campaign_discovery).permit()
  end

end