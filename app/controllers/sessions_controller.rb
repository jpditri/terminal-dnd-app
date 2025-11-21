# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :require_authentication, only: [:new, :create]
  before_action :set_session, only: [:destroy]
  before_action :redirect_if_authenticated, only: [:new, :create]

  def new
    @sessions = Sessions.new
    authorize @sessions
  end

  def create
    @sessions = Sessions.new(sessions_params)
    authorize @sessions

    respond_to do |format|
      if @sessions.save
        format.html { redirect_to @sessions, notice: 'Sessions was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @sessions

    @sessions.destroy

    respond_to do |format|
      format.html { redirect_to sessionses_path, notice: 'Sessions was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_session
    # TODO: Implement set_session
  end

  def redirect_if_authenticated
    # TODO: Implement redirect_if_authenticated
  end

  private

  def set_sessions
    @sessions = Sessions.find(params[:id])
  end

  def sessions_params
    params.require(:sessions).permit()
  end

end