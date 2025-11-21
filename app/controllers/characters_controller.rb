# frozen_string_literal: true

class CharactersController < ApplicationController
  before_action :set_character

  def index
    @characterses = policy_scope(Characters)
    @characterses = @characterses.search(params[:q]) if params[:q].present?
    @characterses = @characterses.page(params[:page]).per(20)
  end

  def show
    authorize @characters
  end

  def edit
    authorize @characters
  end

  def new
    @characters = Characters.new
    authorize @characters
  end

  def create
    @characters = Characters.new(characters_params)
    authorize @characters

    respond_to do |format|
      if @characters.save
        format.html { redirect_to @characters, notice: 'Characters was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @characters

    respond_to do |format|
      if @characters.update(characters_params)
        format.html { redirect_to @characters, notice: 'Characters was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @characters

    @characters.destroy

    respond_to do |format|
      format.html { redirect_to characterses_path, notice: 'Characters was successfully deleted.' }
      format.turbo_stream
    end
  end

  def wizard
    # TODO: Implement wizard
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

  def sheet
    # TODO: Implement sheet
  end

  def print
    # TODO: Implement print
  end

  def update_hp
    # TODO: Implement update_hp
  end

  def state
    # TODO: Implement state
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

  def set_character
    # TODO: Implement set_character
  end

  private

  def set_characters
    @characters = Characters.find(params[:id])
  end

  def characters_params
    params.require(:characters).permit()
  end

end