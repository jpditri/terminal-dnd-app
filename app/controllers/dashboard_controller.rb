# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :set_user_role

  def index
    @dashboards = policy_scope(Dashboard)
    @dashboards = @dashboards.search(params[:q]) if params[:q].present?
    @dashboards = @dashboards.page(params[:page]).per(20)
  end

  def switch_role
    # TODO: Implement switch_role
  end

  def set_user_role
    # TODO: Implement set_user_role
  end

  private

  def set_dashboard
    @dashboard = Dashboard.find(params[:id])
  end

  def dashboard_params
    params.require(:dashboard).permit()
  end

end