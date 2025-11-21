# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :set_user
  before_action :set_notification, only: [:mark_as_read, :destroy]

  def index
    @notificationses = policy_scope(Notifications)
    @notificationses = @notificationses.search(params[:q]) if params[:q].present?
    @notificationses = @notificationses.page(params[:page]).per(20)
  end

  def destroy
    authorize @notifications

    @notifications.destroy

    respond_to do |format|
      format.html { redirect_to notificationses_path, notice: 'Notifications was successfully deleted.' }
      format.turbo_stream
    end
  end

  def mark_as_read
    # TODO: Implement mark_as_read
  end

  def mark_all_as_read
    # TODO: Implement mark_all_as_read
  end

  def destroy_all_read
    # TODO: Implement destroy_all_read
  end

  def unread_count
    # TODO: Implement unread_count
  end

  def set_user
    # TODO: Implement set_user
  end

  def set_notification
    # TODO: Implement set_notification
  end

  private

  def set_notifications
    @notifications = Notifications.find(params[:id])
  end

  def notifications_params
    params.require(:notifications).permit()
  end

end