# frozen_string_literal: true

class GeneratedTreasuresController < ApplicationController
  before_action :set_generated_treasure, only: [:show, :destroy]

  def index
    @generated_treasureses = policy_scope(GeneratedTreasures)
    @generated_treasureses = @generated_treasureses.search(params[:q]) if params[:q].present?
    @generated_treasureses = @generated_treasureses.page(params[:page]).per(20)
  end

  def show
    authorize @generated_treasures
  end

  def destroy
    authorize @generated_treasures

    @generated_treasures.destroy

    respond_to do |format|
      format.html { redirect_to generated_treasureses_path, notice: 'GeneratedTreasures was successfully deleted.' }
      format.turbo_stream
    end
  end

  def set_generated_treasure
    # TODO: Implement set_generated_treasure
  end

  private

  def set_generated_treasures
    @generated_treasures = GeneratedTreasures.find(params[:id])
  end

  def generated_treasures_params
    params.require(:generated_treasures).permit()
  end

end