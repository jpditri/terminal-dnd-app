# frozen_string_literal: true

class CampaignMetricsController < ApplicationController
  before_action :require_authentication
  before_action :set_campaign_metric

  def index
    @campaign_metricses = policy_scope(CampaignMetrics)
    @campaign_metricses = @campaign_metricses.search(params[:q]) if params[:q].present?
    @campaign_metricses = @campaign_metricses.page(params[:page]).per(20)
  end

  def show
    authorize @campaign_metrics
  end

  def generate
    # TODO: Implement generate
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_campaign_metric
    # TODO: Implement set_campaign_metric
  end

  private

  def set_campaign_metrics
    @campaign_metrics = CampaignMetrics.find(params[:id])
  end

  def campaign_metrics_params
    params.require(:campaign_metrics).permit()
  end

end