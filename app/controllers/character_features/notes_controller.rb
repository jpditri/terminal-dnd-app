# frozen_string_literal: true

module CharacterFeatures
  class NotesController < ApplicationController
    before_action :require_authentication
    before_action :set_character
    before_action :set_note, only: [:update, :destroy, :toggle_complete, :toggle_pin]

    def index
      @character_features::noteses = policy_scope(CharacterFeatures::notes)
      @character_features::noteses = @character_features::noteses.search(params[:q]) if params[:q].present?
      @character_features::noteses = @character_features::noteses.page(params[:page]).per(20)
    end

    def create
      @character_features::notes = CharacterFeatures::notes.new(character_features::notes_params)
      authorize @character_features::notes

      respond_to do |format|
        if @character_features::notes.save
          format.html { redirect_to @character_features::notes, notice: 'CharacterFeatures::notes was successfully created.' }
          format.turbo_stream
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      authorize @character_features::notes

      respond_to do |format|
        if @character_features::notes.update(character_features::notes_params)
          format.html { redirect_to @character_features::notes, notice: 'CharacterFeatures::notes was successfully updated.' }
          format.turbo_stream
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @character_features::notes

      @character_features::notes.destroy

      respond_to do |format|
        format.html { redirect_to character_features::noteses_path, notice: 'CharacterFeatures::notes was successfully deleted.' }
        format.turbo_stream
      end
    end

    def search
      # TODO: Implement search
    end

    def toggle_complete
      # TODO: Implement toggle_complete
    end

    def toggle_pin
      # TODO: Implement toggle_pin
    end

    def add_tag
      # TODO: Implement add_tag
    end

    def remove_tag
      # TODO: Implement remove_tag
    end

    def auto_save
      # TODO: Implement auto_save
    end

    def require_authentication
      # TODO: Implement require_authentication
    end

    def set_character
      # TODO: Implement set_character
    end

    def set_note
      # TODO: Implement set_note
    end

    private

    def set_character_features::notes
      @character_features::notes = CharacterFeatures::notes.find(params[:id])
    end

    def character_features::notes_params
      params.require(:character_features::notes).permit()
    end

  end
end