# frozen_string_literal: true

module Campaigns
  class AnalyticsController < ApplicationController
    def index
      @campaigns::analyticses = policy_scope(Campaigns::analytics)
      @campaigns::analyticses = @campaigns::analyticses.search(params[:q]) if params[:q].present?
      @campaigns::analyticses = @campaigns::analyticses.page(params[:page]).per(20)
    end

    def metrics
      # TODO: Implement metrics
    end

    def session_frequency
      # TODO: Implement session_frequency
    end

    def player_att
      # TODO: Implement player_att
    end

    private

    def set_campaigns::analytics
      @campaigns::analytics = Campaigns::analytics.find(params[:id])
    end

    def campaigns::analytics_params
      params.require(:campaigns::analytics).permit()
    end

  end
end