# frozen_string_literal: true

class CharacterItemsController < ApplicationController
  before_action :set_character_item

  def index
    @character_itemses = policy_scope(CharacterItems)
    @character_itemses = @character_itemses.search(params[:q]) if params[:q].present?
    @character_itemses = @character_itemses.page(params[:page]).per(20)
  end

  def show
    authorize @character_items
  end

  def edit
    authorize @character_items
  end

  def new
    @character_items = CharacterItems.new
    authorize @character_items
  end

  def create
    @character_items = CharacterItems.new(character_items_params)
    authorize @character_items

    respond_to do |format|
      if @character_items.save
        format.html { redirect_to @character_items, notice: 'CharacterItems was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @character_items

    respond_to do |format|
      if @character_items.update(character_items_params)
        format.html { redirect_to @character_items, notice: 'CharacterItems was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @character_items

    @character_items.destroy

    respond_to do |format|
      format.html { redirect_to character_itemses_path, notice: 'CharacterItems was successfully deleted.' }
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

  def set_character_item
    # TODO: Implement set_character_item
  end

  private

  def set_character_items
    @character_items = CharacterItems.find(params[:id])
  end

  def character_items_params
    params.require(:character_items).permit()
  end

end