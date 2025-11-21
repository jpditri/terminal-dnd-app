# frozen_string_literal: true

module Homebrew
  class ClassesController < ApplicationController
    before_action :require_authentication
    before_action :set_homebrew_class
    before_action :authorize_edit

    def index
      @homebrew::classeses = policy_scope(Homebrew::classes)
      @homebrew::classeses = @homebrew::classeses.search(params[:q]) if params[:q].present?
      @homebrew::classeses = @homebrew::classeses.page(params[:page]).per(20)
    end

    def show
      authorize @homebrew::classes
    end

    def new
      @homebrew::classes = Homebrew::classes.new
      authorize @homebrew::classes
    end

    def create
      @homebrew::classes = Homebrew::classes.new(homebrew::classes_params)
      authorize @homebrew::classes

      respond_to do |format|
        if @homebrew::classes.save
          format.html { redirect_to @homebrew::classes, notice: 'Homebrew::classes was successfully created.' }
          format.turbo_stream
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      authorize @homebrew::classes
    end

    def update
      authorize @homebrew::classes

      respond_to do |format|
        if @homebrew::classes.update(homebrew::classes_params)
          format.html { redirect_to @homebrew::classes, notice: 'Homebrew::classes was successfully updated.' }
          format.turbo_stream
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @homebrew::classes

      @homebrew::classes.destroy

      respond_to do |format|
        format.html { redirect_to homebrew::classeses_path, notice: 'Homebrew::classes was successfully deleted.' }
        format.turbo_stream
      end
    end

    def analyze_balance
      # TODO: Implement analyze_balance
    end

    def require_authentication
      # TODO: Implement require_authentication
    end

    def set_homebrew_class
      # TODO: Implement set_homebrew_class
    end

    def authorize_edit
      # TODO: Implement authorize_edit
    end

    private

    def set_homebrew::classes
      @homebrew::classes = Homebrew::classes.find(params[:id])
    end

    def homebrew::classes_params
      params.require(:homebrew::classes).permit()
    end

  end
end