# frozen_string_literal: true

class FactionsController < ApplicationController
  before_action :require_authentication
  before_action :set_faction

  def index
    @factionses = policy_scope(Factions)
    @factionses = @factionses.search(params[:q]) if params[:q].present?
    @factionses = @factionses.page(params[:page]).per(20)
  end

  def show
    authorize @factions
  end

  def new
    @factions = Factions.new
    authorize @factions
  end

  def create
    @factions = Factions.new(factions_params)
    authorize @factions

    respond_to do |format|
      if @factions.save
        format.html { redirect_to @factions, notice: 'Factions was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @factions

    respond_to do |format|
      if @factions.update(factions_params)
        format.html { redirect_to @factions, notice: 'Factions was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @factions

    @factions.destroy

    respond_to do |format|
      format.html { redirect_to factionses_path, notice: 'Factions was successfully deleted.' }
      format.turbo_stream
    end
  end

  def restore
    # TODO: Implement restore
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_faction
    # TODO: Implement set_faction
  end

  private

  def set_factions
    @factions = Factions.find(params[:id])
  end

  def factions_params
    params.require(:factions).permit()
  end

end