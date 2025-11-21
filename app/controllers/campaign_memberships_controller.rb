# frozen_string_literal: true

class CampaignMembershipsController < ApplicationController
  before_action :set_campaign_membership

  def index
    @campaign_membershipses = policy_scope(CampaignMemberships)
    @campaign_membershipses = @campaign_membershipses.search(params[:q]) if params[:q].present?
    @campaign_membershipses = @campaign_membershipses.page(params[:page]).per(20)
  end

  def show
    authorize @campaign_memberships
  end

  def edit
    authorize @campaign_memberships
  end

  def new
    @campaign_memberships = CampaignMemberships.new
    authorize @campaign_memberships
  end

  def create
    @campaign_memberships = CampaignMemberships.new(campaign_memberships_params)
    authorize @campaign_memberships

    respond_to do |format|
      if @campaign_memberships.save
        format.html { redirect_to @campaign_memberships, notice: 'CampaignMemberships was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @campaign_memberships

    respond_to do |format|
      if @campaign_memberships.update(campaign_memberships_params)
        format.html { redirect_to @campaign_memberships, notice: 'CampaignMemberships was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @campaign_memberships

    @campaign_memberships.destroy

    respond_to do |format|
      format.html { redirect_to campaign_membershipses_path, notice: 'CampaignMemberships was successfully deleted.' }
      format.turbo_stream
    end
  end

  def inline_update
    # TODO: Implement inline_update
  end

  def restore
    # TODO: Implement restore
  end

  def history
    # TODO: Implement history
  end

  def bulk_destroy
    # TODO: Implement bulk_destroy
  end

  def bulk_restore
    # TODO: Implement bulk_restore
  end

  def export
    # TODO: Implement export
  end

  def set_campaign_membership
    # TODO: Implement set_campaign_membership
  end

  private

  def set_campaign_memberships
    @campaign_memberships = CampaignMemberships.find(params[:id])
  end

  def campaign_memberships_params
    params.require(:campaign_memberships).permit()
  end

end