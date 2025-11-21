# frozen_string_literal: true

class GameSessionsController < ApplicationController
  before_action :set_game_session

  def index
    @game_sessionses = policy_scope(GameSessions)
    @game_sessionses = @game_sessionses.search(params[:q]) if params[:q].present?
    @game_sessionses = @game_sessionses.page(params[:page]).per(20)
  end

  def show
    authorize @game_sessions
  end

  def edit
    authorize @game_sessions
  end

  def new
    @game_sessions = GameSessions.new
    authorize @game_sessions
  end

  def create
    @game_sessions = GameSessions.new(game_sessions_params)
    authorize @game_sessions

    respond_to do |format|
      if @game_sessions.save
        format.html { redirect_to @game_sessions, notice: 'GameSessions was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @game_sessions

    respond_to do |format|
      if @game_sessions.update(game_sessions_params)
        format.html { redirect_to @game_sessions, notice: 'GameSessions was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @game_sessions

    @game_sessions.destroy

    respond_to do |format|
      format.html { redirect_to game_sessionses_path, notice: 'GameSessions was successfully deleted.' }
      format.turbo_stream
    end
  end

  def live
    # TODO: Implement live
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

  def join
    # TODO: Implement join
  end

  def respond_to_invitation
    # TODO: Implement respond_to_invitation
  end

  def export
    # TODO: Implement export
  end

  def set_game_session
    # TODO: Implement set_game_session
  end

  private

  def set_game_sessions
    @game_sessions = GameSessions.find(params[:id])
  end

  def game_sessions_params
    params.require(:game_sessions).permit()
  end

end