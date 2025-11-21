# frozen_string_literal: true

class EncountersController < ApplicationController
  before_action :require_authentication
  before_action :set_encounter

  def index
    @encounterses = policy_scope(Encounters)
    @encounterses = @encounterses.search(params[:q]) if params[:q].present?
    @encounterses = @encounterses.page(params[:page]).per(20)
  end

  def show
    authorize @encounters
  end

  def new
    @encounters = Encounters.new
    authorize @encounters
  end

  def edit
    authorize @encounters
  end

  def create
    @encounters = Encounters.new(encounters_params)
    authorize @encounters

    respond_to do |format|
      if @encounters.save
        format.html { redirect_to @encounters, notice: 'Encounters was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @encounters

    respond_to do |format|
      if @encounters.update(encounters_params)
        format.html { redirect_to @encounters, notice: 'Encounters was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @encounters

    @encounters.destroy

    respond_to do |format|
      format.html { redirect_to encounterses_path, notice: 'Encounters was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_encounter
    # TODO: Implement set_encounter
  end

  private

  def set_encounters
    @encounters = Encounters.find(params[:id])
  end

  def encounters_params
    params.require(:encounters).permit()
  end

end