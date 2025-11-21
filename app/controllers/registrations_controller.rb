# frozen_string_literal: true

class RegistrationsController < ApplicationController
  before_action :require_authentication

  def new
    @registrations = Registrations.new
    authorize @registrations
  end

  def create
    @registrations = Registrations.new(registrations_params)
    authorize @registrations

    respond_to do |format|
      if @registrations.save
        format.html { redirect_to @registrations, notice: 'Registrations was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  private

  def set_registrations
    @registrations = Registrations.find(params[:id])
  end

  def registrations_params
    params.require(:registrations).permit()
  end

end