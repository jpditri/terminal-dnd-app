# frozen_string_literal: true

class TemplateRatingsController < ApplicationController
  before_action :set_user
  before_action :set_campaign_template, only: [:create]
  before_action :set_rating, only: [:update, :destroy, :mark_helpful]

  def create
    @template_ratings = TemplateRatings.new(template_ratings_params)
    authorize @template_ratings

    respond_to do |format|
      if @template_ratings.save
        format.html { redirect_to @template_ratings, notice: 'TemplateRatings was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @template_ratings

    respond_to do |format|
      if @template_ratings.update(template_ratings_params)
        format.html { redirect_to @template_ratings, notice: 'TemplateRatings was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @template_ratings

    @template_ratings.destroy

    respond_to do |format|
      format.html { redirect_to template_ratingses_path, notice: 'TemplateRatings was successfully deleted.' }
      format.turbo_stream
    end
  end

  def mark_helpful
    # TODO: Implement mark_helpful
  end

  def set_user
    # TODO: Implement set_user
  end

  def set_campaign_template
    # TODO: Implement set_campaign_template
  end

  def set_rating
    # TODO: Implement set_rating
  end

  private

  def set_template_ratings
    @template_ratings = TemplateRatings.find(params[:id])
  end

  def template_ratings_params
    params.require(:template_ratings).permit()
  end

end