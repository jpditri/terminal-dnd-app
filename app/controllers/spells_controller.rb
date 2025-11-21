# frozen_string_literal: true

class SpellsController < ApplicationController
  before_action :set_spell

  def index
    @spellses = policy_scope(Spells)
    @spellses = @spellses.search(params[:q]) if params[:q].present?
    @spellses = @spellses.page(params[:page]).per(20)
  end

  def show
    authorize @spells
  end

  def edit
    authorize @spells
  end

  def new
    @spells = Spells.new
    authorize @spells
  end

  def create
    @spells = Spells.new(spells_params)
    authorize @spells

    respond_to do |format|
      if @spells.save
        format.html { redirect_to @spells, notice: 'Spells was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @spells

    respond_to do |format|
      if @spells.update(spells_params)
        format.html { redirect_to @spells, notice: 'Spells was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @spells

    @spells.destroy

    respond_to do |format|
      format.html { redirect_to spellses_path, notice: 'Spells was successfully deleted.' }
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

  def set_spell
    # TODO: Implement set_spell
  end

  private

  def set_spells
    @spells = Spells.find(params[:id])
  end

  def spells_params
    params.require(:spells).permit()
  end

end