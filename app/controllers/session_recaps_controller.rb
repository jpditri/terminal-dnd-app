# frozen_string_literal: true

class SessionRecapsController < ApplicationController
  before_action :require_authentication
  before_action :set_session_recap

  def index
    @session_recapses = policy_scope(SessionRecaps)
    @session_recapses = @session_recapses.search(params[:q]) if params[:q].present?
    @session_recapses = @session_recapses.page(params[:page]).per(20)
  end

  def show
    authorize @session_recaps
  end

  def new
    @session_recaps = SessionRecaps.new
    authorize @session_recaps
  end

  def edit
    authorize @session_recaps
  end

  def create
    @session_recaps = SessionRecaps.new(session_recaps_params)
    authorize @session_recaps

    respond_to do |format|
      if @session_recaps.save
        format.html { redirect_to @session_recaps, notice: 'SessionRecaps was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @session_recaps

    respond_to do |format|
      if @session_recaps.update(session_recaps_params)
        format.html { redirect_to @session_recaps, notice: 'SessionRecaps was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @session_recaps

    @session_recaps.destroy

    respond_to do |format|
      format.html { redirect_to session_recapses_path, notice: 'SessionRecaps was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_session_recap
    # TODO: Implement set_session_recap
  end

  private

  def set_session_recaps
    @session_recaps = SessionRecaps.find(params[:id])
  end

  def session_recaps_params
    params.require(:session_recaps).permit()
  end

end