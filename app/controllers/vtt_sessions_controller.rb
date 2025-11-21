# frozen_string_literal: true

class VttSessionsController < ApplicationController
  def show
    authorize @vtt_sessions
  end

  def create
    @vtt_sessions = VttSessions.new(vtt_sessions_params)
    authorize @vtt_sessions

    respond_to do |format|
      if @vtt_sessions.save
        format.html { redirect_to @vtt_sessions, notice: 'VttSessions was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @vtt_sessions

    @vtt_sessions.destroy

    respond_to do |format|
      format.html { redirect_to vtt_sessionses_path, notice: 'VttSessions was successfully deleted.' }
      format.turbo_stream
    end
  end

  def load_encounter
    # TODO: Implement load_encounter
  end

  private

  def set_vtt_sessions
    @vtt_sessions = VttSessions.find(params[:id])
  end

  def vtt_sessions_params
    params.require(:vtt_sessions).permit()
  end

end