# frozen_string_literal: true

class CharacterSpellsController < ApplicationController
  before_action :set_character_spell

  def index
    @character_spellses = policy_scope(CharacterSpells)
    @character_spellses = @character_spellses.search(params[:q]) if params[:q].present?
    @character_spellses = @character_spellses.page(params[:page]).per(20)
  end

  def show
    authorize @character_spells
  end

  def edit
    authorize @character_spells
  end

  def new
    @character_spells = CharacterSpells.new
    authorize @character_spells
  end

  def create
    @character_spells = CharacterSpells.new(character_spells_params)
    authorize @character_spells

    respond_to do |format|
      if @character_spells.save
        format.html { redirect_to @character_spells, notice: 'CharacterSpells was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @character_spells

    respond_to do |format|
      if @character_spells.update(character_spells_params)
        format.html { redirect_to @character_spells, notice: 'CharacterSpells was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @character_spells

    @character_spells.destroy

    respond_to do |format|
      format.html { redirect_to character_spellses_path, notice: 'CharacterSpells was successfully deleted.' }
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

  def set_character_spell
    # TODO: Implement set_character_spell
  end

  private

  def set_character_spells
    @character_spells = CharacterSpells.find(params[:id])
  end

  def character_spells_params
    params.require(:character_spells).permit()
  end

end