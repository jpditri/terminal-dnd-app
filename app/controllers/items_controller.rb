# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :set_item

  def index
    @itemses = policy_scope(Items)
    @itemses = @itemses.search(params[:q]) if params[:q].present?
    @itemses = @itemses.page(params[:page]).per(20)
  end

  def show
    authorize @items
  end

  def edit
    authorize @items
  end

  def new
    @items = Items.new
    authorize @items
  end

  def create
    @items = Items.new(items_params)
    authorize @items

    respond_to do |format|
      if @items.save
        format.html { redirect_to @items, notice: 'Items was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @items

    respond_to do |format|
      if @items.update(items_params)
        format.html { redirect_to @items, notice: 'Items was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @items

    @items.destroy

    respond_to do |format|
      format.html { redirect_to itemses_path, notice: 'Items was successfully deleted.' }
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

  def set_item
    # TODO: Implement set_item
  end

  private

  def set_items
    @items = Items.find(params[:id])
  end

  def items_params
    params.require(:items).permit()
  end

end