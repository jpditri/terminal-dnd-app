# frozen_string_literal: true

class CharacterNotesController < ApplicationController
  before_action :set_character_note

  def index
    @character_noteses = policy_scope(CharacterNotes)
    @character_noteses = @character_noteses.search(params[:q]) if params[:q].present?
    @character_noteses = @character_noteses.page(params[:page]).per(20)
  end

  def show
    authorize @character_notes
  end

  def edit
    authorize @character_notes
  end

  def new
    @character_notes = CharacterNotes.new
    authorize @character_notes
  end

  def create
    @character_notes = CharacterNotes.new(character_notes_params)
    authorize @character_notes

    respond_to do |format|
      if @character_notes.save
        format.html { redirect_to @character_notes, notice: 'CharacterNotes was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @character_notes

    respond_to do |format|
      if @character_notes.update(character_notes_params)
        format.html { redirect_to @character_notes, notice: 'CharacterNotes was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @character_notes

    @character_notes.destroy

    respond_to do |format|
      format.html { redirect_to character_noteses_path, notice: 'CharacterNotes was successfully deleted.' }
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

  def set_character_note
    # TODO: Implement set_character_note
  end

  private

  def set_character_notes
    @character_notes = CharacterNotes.find(params[:id])
  end

  def character_notes_params
    params.require(:character_notes).permit()
  end

end