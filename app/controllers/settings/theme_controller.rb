# frozen_string_literal: true

module Settings
  class ThemeController < ApplicationController
    before_action :require_authentication
    before_action :set_theme_preference, only: [:show]

    def show
      authorize @settings::them
    end

    def update
      authorize @settings::them

      respond_to do |format|
        if @settings::them.update(settings::them_params)
          format.html { redirect_to @settings::them, notice: 'Settings::them was successfully updated.' }
          format.turbo_stream
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def apply_preset
      # TODO: Implement apply_preset
    end

    def reset
      # TODO: Implement reset
    end

    def export
      # TODO: Implement export
    end

    def require_authentication
      # TODO: Implement require_authentication
    end

    def set_theme_preference
      # TODO: Implement set_theme_preference
    end

    private

    def set_settings::them
      @settings::them = Settings::them.find(params[:id])
    end

    def settings::them_params
      params.require(:settings::them).permit()
    end

  end
end