# frozen_string_literal: true

class HealthController < ApplicationController
  before_action :require_authentication

  def index
    @healths = policy_scope(Health)
    @healths = @healths.search(params[:q]) if params[:q].present?
    @healths = @healths.page(params[:page]).per(20)
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  private

  def set_health
    @health = Health.find(params[:id])
  end

  def health_params
    params.require(:health).permit()
  end

end