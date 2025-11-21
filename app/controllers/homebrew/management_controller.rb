# frozen_string_literal: true

module Homebrew
  class ManagementController < ApplicationController
    before_action :require_authentication

    def index
      @homebrew::managements = policy_scope(Homebrew::management)
      @homebrew::managements = @homebrew::managements.search(params[:q]) if params[:q].present?
      @homebrew::managements = @homebrew::managements.page(params[:page]).per(20)
    end

    def export
      # TODO: Implement export
    end

    def import
      # TODO: Implement import
    end

    def require_authentication
      # TODO: Implement require_authentication
    end

    private

    def set_homebrew::management
      @homebrew::management = Homebrew::management.find(params[:id])
    end

    def homebrew::management_params
      params.require(:homebrew::management).permit()
    end

  end
end