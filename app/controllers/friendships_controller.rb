# frozen_string_literal: true

class FriendshipsController < ApplicationController
  before_action :set_user

  def index
    @friendshipses = policy_scope(Friendships)
    @friendshipses = @friendshipses.search(params[:q]) if params[:q].present?
    @friendshipses = @friendshipses.page(params[:page]).per(20)
  end

  def destroy
    authorize @friendships

    @friendships.destroy

    respond_to do |format|
      format.html { redirect_to friendshipses_path, notice: 'Friendships was successfully deleted.' }
      format.turbo_stream
    end
  end

  def set_user
    # TODO: Implement set_user
  end

  private

  def set_friendships
    @friendships = Friendships.find(params[:id])
  end

  def friendships_params
    params.require(:friendships).permit()
  end

end