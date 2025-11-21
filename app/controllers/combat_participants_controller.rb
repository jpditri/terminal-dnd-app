# frozen_string_literal: true

class CombatParticipantsController < ApplicationController
  before_action :require_authentication
  before_action :set_combat_participant

  def index
    @combat_participantses = policy_scope(CombatParticipants)
    @combat_participantses = @combat_participantses.search(params[:q]) if params[:q].present?
    @combat_participantses = @combat_participantses.page(params[:page]).per(20)
  end

  def show
    authorize @combat_participants
  end

  def new
    @combat_participants = CombatParticipants.new
    authorize @combat_participants
  end

  def edit
    authorize @combat_participants
  end

  def create
    @combat_participants = CombatParticipants.new(combat_participants_params)
    authorize @combat_participants

    respond_to do |format|
      if @combat_participants.save
        format.html { redirect_to @combat_participants, notice: 'CombatParticipants was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @combat_participants

    respond_to do |format|
      if @combat_participants.update(combat_participants_params)
        format.html { redirect_to @combat_participants, notice: 'CombatParticipants was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @combat_participants

    @combat_participants.destroy

    respond_to do |format|
      format.html { redirect_to combat_participantses_path, notice: 'CombatParticipants was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_combat_participant
    # TODO: Implement set_combat_participant
  end

  private

  def set_combat_participants
    @combat_participants = CombatParticipants.find(params[:id])
  end

  def combat_participants_params
    params.require(:combat_participants).permit()
  end

end