# frozen_string_literal: true

class FriendRequestsController < ApplicationController
  before_action :set_user
  before_action :set_fri

  def index
    @friend_requestses = policy_scope(FriendRequests)
    @friend_requestses = @friend_requestses.search(params[:q]) if params[:q].present?
    @friend_requestses = @friend_requestses.page(params[:page]).per(20)
  end

  def show
    authorize @friend_requests
  end

  def create
    @friend_requests = FriendRequests.new(friend_requests_params)
    authorize @friend_requests

    respond_to do |format|
      if @friend_requests.save
        format.html { redirect_to @friend_requests, notice: 'FriendRequests was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @friend_requests

    @friend_requests.destroy

    respond_to do |format|
      format.html { redirect_to friend_requestses_path, notice: 'FriendRequests was successfully deleted.' }
      format.turbo_stream
    end
  end

  def accept
    # TODO: Implement accept
  end

  def decline
    # TODO: Implement decline
  end

  def set_user
    # TODO: Implement set_user
  end

  def set_fri
    # TODO: Implement set_fri
  end

  private

  def set_friend_requests
    @friend_requests = FriendRequests.find(params[:id])
  end

  def friend_requests_params
    params.require(:friend_requests).permit()
  end

end