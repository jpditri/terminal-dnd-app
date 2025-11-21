# frozen_string_literal: true

class RacesController < ApplicationController
  before_action :set_race

  def index
    @raceses = policy_scope(Races)
    @raceses = @raceses.search(params[:q]) if params[:q].present?
    @raceses = @raceses.page(params[:page]).per(20)
  end

  def show
    authorize @races
  end

  def edit
    authorize @races
  end

  def new
    @races = Races.new
    authorize @races
  end

  def create
    @races = Races.new(races_params)
    authorize @races

    respond_to do |format|
      if @races.save
        format.html { redirect_to @races, notice: 'Races was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @races

    respond_to do |format|
      if @races.update(races_params)
        format.html { redirect_to @races, notice: 'Races was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @races

    @races.destroy

    respond_to do |format|
      format.html { redirect_to raceses_path, notice: 'Races was successfully deleted.' }
      format.turbo_stream
    end
  end

  def inline_update
    # TODO: Implement inline_update
  end

  def restore
    # TODO: Implement restore
  end

  def history
    # TODO: Implement history
  end

  def bulk_destroy
    # TODO: Implement bulk_destroy
  end

  def bulk_restore
    # TODO: Implement bulk_restore
  end

  def export
    # TODO: Implement export
  end

  def set_race
    # TODO: Implement set_race
  end

  private

  def set_races
    @races = Races.find(params[:id])
  end

  def races_params
    params.require(:races).permit()
  end

end