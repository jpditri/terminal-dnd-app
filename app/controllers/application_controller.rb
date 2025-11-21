# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit

  def set_paper_trail_whodunnit
    # TODO: Implement set_paper_trail_whodunnit
  end

  private

  def set_application
    @application = Application.find(params[:id])
  end

  def application_params
    params.require(:application).permit()
  end

end