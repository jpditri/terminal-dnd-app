# frozen_string_literal: true

class MapsController < ApplicationController
  before_action :require_authentication
  before_action :set_map

  def index
    @mapses = policy_scope(Maps)
    @mapses = @mapses.search(params[:q]) if params[:q].present?
    @mapses = @mapses.page(params[:page]).per(20)
  end

  def show
    authorize @maps
  end

  def new
    @maps = Maps.new
    authorize @maps
  end

  def edit
    authorize @maps
  end

  def create
    @maps = Maps.new(maps_params)
    authorize @maps

    respond_to do |format|
      if @maps.save
        format.html { redirect_to @maps, notice: 'Maps was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @maps

    respond_to do |format|
      if @maps.update(maps_params)
        format.html { redirect_to @maps, notice: 'Maps was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @maps

    @maps.destroy

    respond_to do |format|
      format.html { redirect_to mapses_path, notice: 'Maps was successfully deleted.' }
      format.turbo_stream
    end
  end

  def dm_view
    # TODO: Implement dm_view
  end

  def player_view
    # TODO: Implement player_view
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_map
    # TODO: Implement set_map
  end

  private

  def set_maps
    @maps = Maps.find(params[:id])
  end

  def maps_params
    params.require(:maps).permit()
  end

end