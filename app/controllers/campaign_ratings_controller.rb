# frozen_string_literal: true

class CampaignRatingsController < ApplicationController
  before_action :set_user
  before_action :set_campaign, only: [:create]
  before_action :set_rating, only: [:update, :destroy]

  def create
    @campaign_ratings = CampaignRatings.new(campaign_ratings_params)
    authorize @campaign_ratings

    respond_to do |format|
      if @campaign_ratings.save
        format.html { redirect_to @campaign_ratings, notice: 'CampaignRatings was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @campaign_ratings

    respond_to do |format|
      if @campaign_ratings.update(campaign_ratings_params)
        format.html { redirect_to @campaign_ratings, notice: 'CampaignRatings was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @campaign_ratings

    @campaign_ratings.destroy

    respond_to do |format|
      format.html { redirect_to campaign_ratingses_path, notice: 'CampaignRatings was successfully deleted.' }
      format.turbo_stream
    end
  end

  def set_user
    # TODO: Implement set_user
  end

  def set_campaign
    # TODO: Implement set_campaign
  end

  def set_rating
    # TODO: Implement set_rating
  end

  private

  def set_campaign_ratings
    @campaign_ratings = CampaignRatings.find(params[:id])
  end

  def campaign_ratings_params
    params.require(:campaign_ratings).permit()
  end

end