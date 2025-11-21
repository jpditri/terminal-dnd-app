# frozen_string_literal: true

module Homebrew
  class SpellsController < ApplicationController
    before_action :require_authentication
    before_action :set_homebrew_spell
    before_action :authorize_edit

    def index
      @homebrew::spellses = policy_scope(Homebrew::spells)
      @homebrew::spellses = @homebrew::spellses.search(params[:q]) if params[:q].present?
      @homebrew::spellses = @homebrew::spellses.page(params[:page]).per(20)
    end

    def show
      authorize @homebrew::spells
    end

    def new
      @homebrew::spells = Homebrew::spells.new
      authorize @homebrew::spells
    end

    def create
      @homebrew::spells = Homebrew::spells.new(homebrew::spells_params)
      authorize @homebrew::spells

      respond_to do |format|
        if @homebrew::spells.save
          format.html { redirect_to @homebrew::spells, notice: 'Homebrew::spells was successfully created.' }
          format.turbo_stream
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      authorize @homebrew::spells
    end

    def update
      authorize @homebrew::spells

      respond_to do |format|
        if @homebrew::spells.update(homebrew::spells_params)
          format.html { redirect_to @homebrew::spells, notice: 'Homebrew::spells was successfully updated.' }
          format.turbo_stream
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @homebrew::spells

      @homebrew::spells.destroy

      respond_to do |format|
        format.html { redirect_to homebrew::spellses_path, notice: 'Homebrew::spells was successfully deleted.' }
        format.turbo_stream
      end
    end

    def analyze_balance
      # TODO: Implement analyze_balance
    end

    def require_authentication
      # TODO: Implement require_authentication
    end

    def set_homebrew_spell
      # TODO: Implement set_homebrew_spell
    end

    def authorize_edit
      # TODO: Implement authorize_edit
    end

    private

    def set_homebrew::spells
      @homebrew::spells = Homebrew::spells.find(params[:id])
    end

    def homebrew::spells_params
      params.require(:homebrew::spells).permit()
    end

  end
end