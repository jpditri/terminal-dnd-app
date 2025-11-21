# frozen_string_literal: true

class ActivityController < ApplicationController
  def index
    @activities = policy_scope(Activity)
    @activities = @activities.search(params[:q]) if params[:q].present?
    @activities = @activities.page(params[:page]).per(20)
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  end

  def activity_params
    params.require(:activity).permit()
  end

end