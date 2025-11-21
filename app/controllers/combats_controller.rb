# frozen_string_literal: true

class CombatsController < ApplicationController
  def index
    @combatses = policy_scope(Combats)
    @combatses = @combatses.search(params[:q]) if params[:q].present?
    @combatses = @combatses.page(params[:page]).per(20)
  end

  def show
    authorize @combats
  end

  def new
    @combats = Combats.new
    authorize @combats
  end

  def edit
    authorize @combats
  end

  def create
    @combats = Combats.new(combats_params)
    authorize @combats

    respond_to do |format|
      if @combats.save
        format.html { redirect_to @combats, notice: 'Combats was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @combats

    respond_to do |format|
      if @combats.update(combats_params)
        format.html { redirect_to @combats, notice: 'Combats was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @combats

    @combats.destroy

    respond_to do |format|
      format.html { redirect_to combatses_path, notice: 'Combats was successfully deleted.' }
      format.turbo_stream
    end
  end

  def next_turn
    # TODO: Implement next_turn
  end

  private

  def set_combats
    @combats = Combats.find(params[:id])
  end

  def combats_params
    params.require(:combats).permit()
  end

end