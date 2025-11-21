# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :require_authentication
  before_action :set_location

  def index
    @locationses = policy_scope(Locations)
    @locationses = @locationses.search(params[:q]) if params[:q].present?
    @locationses = @locationses.page(params[:page]).per(20)
  end

  def show
    authorize @locations
  end

  def new
    @locations = Locations.new
    authorize @locations
  end

  def create
    @locations = Locations.new(locations_params)
    authorize @locations

    respond_to do |format|
      if @locations.save
        format.html { redirect_to @locations, notice: 'Locations was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @locations

    respond_to do |format|
      if @locations.update(locations_params)
        format.html { redirect_to @locations, notice: 'Locations was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @locations

    @locations.destroy

    respond_to do |format|
      format.html { redirect_to locationses_path, notice: 'Locations was successfully deleted.' }
      format.turbo_stream
    end
  end

  def restore
    # TODO: Implement restore
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_location
    # TODO: Implement set_location
  end

  private

  def set_locations
    @locations = Locations.find(params[:id])
  end

  def locations_params
    params.require(:locations).permit()
  end

end