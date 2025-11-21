# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :set_campaign

  def index
    @campaignses = policy_scope(Campaigns)
    @campaignses = @campaignses.search(params[:q]) if params[:q].present?
    @campaignses = @campaignses.page(params[:page]).per(20)
  end

  def show
    authorize @campaigns
  end

  def edit
    authorize @campaigns
  end

  def new
    @campaigns = Campaigns.new
    authorize @campaigns
  end

  def create
    @campaigns = Campaigns.new(campaigns_params)
    authorize @campaigns

    respond_to do |format|
      if @campaigns.save
        format.html { redirect_to @campaigns, notice: 'Campaigns was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @campaigns

    respond_to do |format|
      if @campaigns.update(campaigns_params)
        format.html { redirect_to @campaigns, notice: 'Campaigns was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @campaigns

    @campaigns.destroy

    respond_to do |format|
      format.html { redirect_to campaignses_path, notice: 'Campaigns was successfully deleted.' }
      format.turbo_stream
    end
  end

  def party_data
    # TODO: Implement party_data
  end

  def dm_panel
    # TODO: Implement dm_panel
  end

  def async_panel
    # TODO: Implement async_panel
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

  def dashboard
    # TODO: Implement dashboard
  end

  def quick_start_session
    # TODO: Implement quick_start_session
  end

  def quick_add_npc
    # TODO: Implement quick_add_npc
  end

  def quick_create_quest
    # TODO: Implement quick_create_quest
  end

  def roll_initiative
    # TODO: Implement roll_initiative
  end

  def activity_feed
    # TODO: Implement activity_feed
  end

  def quest_progress
    # TODO: Implement quest_progress
  end

  def player_status
    # TODO: Implement player_status
  end

  def set_campaign
    # TODO: Implement set_campaign
  end

  private

  def set_campaigns
    @campaigns = Campaigns.find(params[:id])
  end

  def campaigns_params
    params.require(:campaigns).permit()
  end

end