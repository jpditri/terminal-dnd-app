# frozen_string_literal: true

class SoloGameStatesController < ApplicationController
  before_action :set_solo_game_state

  def index
    @solo_game_stateses = policy_scope(SoloGameStates)
    @solo_game_stateses = @solo_game_stateses.search(params[:q]) if params[:q].present?
    @solo_game_stateses = @solo_game_stateses.page(params[:page]).per(20)
  end

  def show
    authorize @solo_game_states
  end

  def edit
    authorize @solo_game_states
  end

  def new
    @solo_game_states = SoloGameStates.new
    authorize @solo_game_states
  end

  def create
    @solo_game_states = SoloGameStates.new(solo_game_states_params)
    authorize @solo_game_states

    respond_to do |format|
      if @solo_game_states.save
        format.html { redirect_to @solo_game_states, notice: 'SoloGameStates was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @solo_game_states

    respond_to do |format|
      if @solo_game_states.update(solo_game_states_params)
        format.html { redirect_to @solo_game_states, notice: 'SoloGameStates was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @solo_game_states

    @solo_game_states.destroy

    respond_to do |format|
      format.html { redirect_to solo_game_stateses_path, notice: 'SoloGameStates was successfully deleted.' }
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

  def set_solo_game_state
    # TODO: Implement set_solo_game_state
  end

  private

  def set_solo_game_states
    @solo_game_states = SoloGameStates.find(params[:id])
  end

  def solo_game_states_params
    params.require(:solo_game_states).permit()
  end

end