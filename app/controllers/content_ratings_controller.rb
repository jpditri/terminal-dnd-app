# frozen_string_literal: true

class ContentRatingsController < ApplicationController
  before_action :set_user
  before_action :set_shared_content, only: [:create]
  before_action :set_rating, only: [:update, :destroy, :mark_helpful]

  def create
    @content_ratings = ContentRatings.new(content_ratings_params)
    authorize @content_ratings

    respond_to do |format|
      if @content_ratings.save
        format.html { redirect_to @content_ratings, notice: 'ContentRatings was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @content_ratings

    respond_to do |format|
      if @content_ratings.update(content_ratings_params)
        format.html { redirect_to @content_ratings, notice: 'ContentRatings was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @content_ratings

    @content_ratings.destroy

    respond_to do |format|
      format.html { redirect_to content_ratingses_path, notice: 'ContentRatings was successfully deleted.' }
      format.turbo_stream
    end
  end

  def mark_helpful
    # TODO: Implement mark_helpful
  end

  def set_user
    # TODO: Implement set_user
  end

  def set_shared_content
    # TODO: Implement set_shared_content
  end

  def set_rating
    # TODO: Implement set_rating
  end

  private

  def set_content_ratings
    @content_ratings = ContentRatings.find(params[:id])
  end

  def content_ratings_params
    params.require(:content_ratings).permit()
  end

end