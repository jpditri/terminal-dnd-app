# frozen_string_literal: true

class PlayerEngagementsController < ApplicationController
  before_action :require_authentication
  before_action :set_player_engagement

  def index
    @player_engagementses = policy_scope(PlayerEngagements)
    @player_engagementses = @player_engagementses.search(params[:q]) if params[:q].present?
    @player_engagementses = @player_engagementses.page(params[:page]).per(20)
  end

  def show
    authorize @player_engagements
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_player_engagement
    # TODO: Implement set_player_engagement
  end

  private

  def set_player_engagements
    @player_engagements = PlayerEngagements.find(params[:id])
  end

  def player_engagements_params
    params.require(:player_engagements).permit()
  end

end