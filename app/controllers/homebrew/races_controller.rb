# frozen_string_literal: true

module Homebrew
  class RacesController < ApplicationController
    before_action :require_authentication
    before_action :set_homebrew_race
    before_action :authorize_edit

    def index
      @homebrew::raceses = policy_scope(Homebrew::races)
      @homebrew::raceses = @homebrew::raceses.search(params[:q]) if params[:q].present?
      @homebrew::raceses = @homebrew::raceses.page(params[:page]).per(20)
    end

    def show
      authorize @homebrew::races
    end

    def new
      @homebrew::races = Homebrew::races.new
      authorize @homebrew::races
    end

    def create
      @homebrew::races = Homebrew::races.new(homebrew::races_params)
      authorize @homebrew::races

      respond_to do |format|
        if @homebrew::races.save
          format.html { redirect_to @homebrew::races, notice: 'Homebrew::races was successfully created.' }
          format.turbo_stream
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      authorize @homebrew::races
    end

    def update
      authorize @homebrew::races

      respond_to do |format|
        if @homebrew::races.update(homebrew::races_params)
          format.html { redirect_to @homebrew::races, notice: 'Homebrew::races was successfully updated.' }
          format.turbo_stream
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @homebrew::races

      @homebrew::races.destroy

      respond_to do |format|
        format.html { redirect_to homebrew::raceses_path, notice: 'Homebrew::races was successfully deleted.' }
        format.turbo_stream
      end
    end

    def analyze_balance
      # TODO: Implement analyze_balance
    end

    def require_authentication
      # TODO: Implement require_authentication
    end

    def set_homebrew_race
      # TODO: Implement set_homebrew_race
    end

    def authorize_edit
      # TODO: Implement authorize_edit
    end

    private

    def set_homebrew::races
      @homebrew::races = Homebrew::races.find(params[:id])
    end

    def homebrew::races_params
      params.require(:homebrew::races).permit()
    end

  end
end