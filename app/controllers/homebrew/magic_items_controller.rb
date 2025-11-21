# frozen_string_literal: true

module Homebrew
  class MagicItemsController < ApplicationController
    before_action :require_authentication
    before_action :set_magic_item
    before_action :authorize_edit

    def index
      @homebrew::magic_itemses = policy_scope(Homebrew::magicItems)
      @homebrew::magic_itemses = @homebrew::magic_itemses.search(params[:q]) if params[:q].present?
      @homebrew::magic_itemses = @homebrew::magic_itemses.page(params[:page]).per(20)
    end

    def show
      authorize @homebrew::magic_items
    end

    def new
      @homebrew::magic_items = Homebrew::magicItems.new
      authorize @homebrew::magic_items
    end

    def create
      @homebrew::magic_items = Homebrew::magicItems.new(homebrew::magic_items_params)
      authorize @homebrew::magic_items

      respond_to do |format|
        if @homebrew::magic_items.save
          format.html { redirect_to @homebrew::magic_items, notice: 'Homebrew::magicItems was successfully created.' }
          format.turbo_stream
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      authorize @homebrew::magic_items
    end

    def update
      authorize @homebrew::magic_items

      respond_to do |format|
        if @homebrew::magic_items.update(homebrew::magic_items_params)
          format.html { redirect_to @homebrew::magic_items, notice: 'Homebrew::magicItems was successfully updated.' }
          format.turbo_stream
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @homebrew::magic_items

      @homebrew::magic_items.destroy

      respond_to do |format|
        format.html { redirect_to homebrew::magic_itemses_path, notice: 'Homebrew::magicItems was successfully deleted.' }
        format.turbo_stream
      end
    end

    def analyze_balance
      # TODO: Implement analyze_balance
    end

    def require_authentication
      # TODO: Implement require_authentication
    end

    def set_magic_item
      # TODO: Implement set_magic_item
    end

    def authorize_edit
      # TODO: Implement authorize_edit
    end

    private

    def set_homebrew::magic_items
      @homebrew::magic_items = Homebrew::magicItems.find(params[:id])
    end

    def homebrew::magic_items_params
      params.require(:homebrew::magic_items).permit()
    end

  end
end