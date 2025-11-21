# frozen_string_literal: true

class CampaignJoinRequestsController < ApplicationController
  before_action :set_user
  before_action :set_campaign, only: [:create]
  before_action :set_join_request, only: [:approve, :decline, :destroy]

  def index
    @campaign_join_requestses = policy_scope(CampaignJoinRequests)
    @campaign_join_requestses = @campaign_join_requestses.search(params[:q]) if params[:q].present?
    @campaign_join_requestses = @campaign_join_requestses.page(params[:page]).per(20)
  end

  def create
    @campaign_join_requests = CampaignJoinRequests.new(campaign_join_requests_params)
    authorize @campaign_join_requests

    respond_to do |format|
      if @campaign_join_requests.save
        format.html { redirect_to @campaign_join_requests, notice: 'CampaignJoinRequests was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @campaign_join_requests

    @campaign_join_requests.destroy

    respond_to do |format|
      format.html { redirect_to campaign_join_requestses_path, notice: 'CampaignJoinRequests was successfully deleted.' }
      format.turbo_stream
    end
  end

  def approve
    # TODO: Implement approve
  end

  def decline
    # TODO: Implement decline
  end

  def set_user
    # TODO: Implement set_user
  end

  def set_campaign
    # TODO: Implement set_campaign
  end

  def set_join_request
    # TODO: Implement set_join_request
  end

  private

  def set_campaign_join_requests
    @campaign_join_requests = CampaignJoinRequests.find(params[:id])
  end

  def campaign_join_requests_params
    params.require(:campaign_join_requests).permit()
  end

end