# frozen_string_literal: true

class HomebrewItemsController < ApplicationController
  before_action :require_authentication
  before_action :set_homebrew_item

  def index
    @homebrew_itemses = policy_scope(HomebrewItems)
    @homebrew_itemses = @homebrew_itemses.search(params[:q]) if params[:q].present?
    @homebrew_itemses = @homebrew_itemses.page(params[:page]).per(20)
  end

  def show
    authorize @homebrew_items
  end

  def new
    @homebrew_items = HomebrewItems.new
    authorize @homebrew_items
  end

  def edit
    authorize @homebrew_items
  end

  def create
    @homebrew_items = HomebrewItems.new(homebrew_items_params)
    authorize @homebrew_items

    respond_to do |format|
      if @homebrew_items.save
        format.html { redirect_to @homebrew_items, notice: 'HomebrewItems was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @homebrew_items

    respond_to do |format|
      if @homebrew_items.update(homebrew_items_params)
        format.html { redirect_to @homebrew_items, notice: 'HomebrewItems was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @homebrew_items

    @homebrew_items.destroy

    respond_to do |format|
      format.html { redirect_to homebrew_itemses_path, notice: 'HomebrewItems was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_homebrew_item
    # TODO: Implement set_homebrew_item
  end

  private

  def set_homebrew_items
    @homebrew_items = HomebrewItems.find(params[:id])
  end

  def homebrew_items_params
    params.require(:homebrew_items).permit()
  end

end