# frozen_string_literal: true

class CampaignNotesController < ApplicationController
  before_action :set_campaign_note

  def index
    @campaign_noteses = policy_scope(CampaignNotes)
    @campaign_noteses = @campaign_noteses.search(params[:q]) if params[:q].present?
    @campaign_noteses = @campaign_noteses.page(params[:page]).per(20)
  end

  def show
    authorize @campaign_notes
  end

  def edit
    authorize @campaign_notes
  end

  def new
    @campaign_notes = CampaignNotes.new
    authorize @campaign_notes
  end

  def create
    @campaign_notes = CampaignNotes.new(campaign_notes_params)
    authorize @campaign_notes

    respond_to do |format|
      if @campaign_notes.save
        format.html { redirect_to @campaign_notes, notice: 'CampaignNotes was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @campaign_notes

    respond_to do |format|
      if @campaign_notes.update(campaign_notes_params)
        format.html { redirect_to @campaign_notes, notice: 'CampaignNotes was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @campaign_notes

    @campaign_notes.destroy

    respond_to do |format|
      format.html { redirect_to campaign_noteses_path, notice: 'CampaignNotes was successfully deleted.' }
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

  def set_campaign_note
    # TODO: Implement set_campaign_note
  end

  private

  def set_campaign_notes
    @campaign_notes = CampaignNotes.find(params[:id])
  end

  def campaign_notes_params
    params.require(:campaign_notes).permit()
  end

end