# frozen_string_literal: true

class GameSessionParticipantsController < ApplicationController
  before_action :set_game_session_participant

  def index
    @game_session_participantses = policy_scope(GameSessionParticipants)
    @game_session_participantses = @game_session_participantses.search(params[:q]) if params[:q].present?
    @game_session_participantses = @game_session_participantses.page(params[:page]).per(20)
  end

  def show
    authorize @game_session_participants
  end

  def edit
    authorize @game_session_participants
  end

  def new
    @game_session_participants = GameSessionParticipants.new
    authorize @game_session_participants
  end

  def create
    @game_session_participants = GameSessionParticipants.new(game_session_participants_params)
    authorize @game_session_participants

    respond_to do |format|
      if @game_session_participants.save
        format.html { redirect_to @game_session_participants, notice: 'GameSessionParticipants was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @game_session_participants

    respond_to do |format|
      if @game_session_participants.update(game_session_participants_params)
        format.html { redirect_to @game_session_participants, notice: 'GameSessionParticipants was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @game_session_participants

    @game_session_participants.destroy

    respond_to do |format|
      format.html { redirect_to game_session_participantses_path, notice: 'GameSessionParticipants was successfully deleted.' }
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

  def export
    # TODO: Implement export
  end

  def set_game_session_participant
    # TODO: Implement set_game_session_participant
  end

  private

  def set_game_session_participants
    @game_session_participants = GameSessionParticipants.find(params[:id])
  end

  def game_session_participants_params
    params.require(:game_session_participants).permit()
  end

end