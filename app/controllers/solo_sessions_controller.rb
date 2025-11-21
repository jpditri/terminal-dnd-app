# frozen_string_literal: true

class SoloSessionsController < ApplicationController
  before_action :set_solo_session

  def index
    @solo_sessionses = policy_scope(SoloSessions)
    @solo_sessionses = @solo_sessionses.search(params[:q]) if params[:q].present?
    @solo_sessionses = @solo_sessionses.page(params[:page]).per(20)
  end

  def show
    authorize @solo_sessions
  end

  def edit
    authorize @solo_sessions
  end

  def new
    @solo_sessions = SoloSessions.new
    authorize @solo_sessions
  end

  def create
    @solo_sessions = SoloSessions.new(solo_sessions_params)
    authorize @solo_sessions

    respond_to do |format|
      if @solo_sessions.save
        format.html { redirect_to @solo_sessions, notice: 'SoloSessions was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @solo_sessions

    respond_to do |format|
      if @solo_sessions.update(solo_sessions_params)
        format.html { redirect_to @solo_sessions, notice: 'SoloSessions was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @solo_sessions

    @solo_sessions.destroy

    respond_to do |format|
      format.html { redirect_to solo_sessionses_path, notice: 'SoloSessions was successfully deleted.' }
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

  def quick_adventure
    # TODO: Implement quick_adventure
  end

  def export
    # TODO: Implement export
  end

  def set_solo_session
    # TODO: Implement set_solo_session
  end

  private

  def set_solo_sessions
    @solo_sessions = SoloSessions.find(params[:id])
  end

  def solo_sessions_params
    params.require(:solo_sessions).permit()
  end

end