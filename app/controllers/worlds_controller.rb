# frozen_string_literal: true

class WorldsController < ApplicationController
  before_action :set_world

  def index
    @worldses = policy_scope(Worlds)
    @worldses = @worldses.search(params[:q]) if params[:q].present?
    @worldses = @worldses.page(params[:page]).per(20)
  end

  def show
    authorize @worlds
  end

  def edit
    authorize @worlds
  end

  def new
    @worlds = Worlds.new
    authorize @worlds
  end

  def create
    @worlds = Worlds.new(worlds_params)
    authorize @worlds

    respond_to do |format|
      if @worlds.save
        format.html { redirect_to @worlds, notice: 'Worlds was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @worlds

    respond_to do |format|
      if @worlds.update(worlds_params)
        format.html { redirect_to @worlds, notice: 'Worlds was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @worlds

    @worlds.destroy

    respond_to do |format|
      format.html { redirect_to worldses_path, notice: 'Worlds was successfully deleted.' }
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

  def set_world
    # TODO: Implement set_world
  end

  private

  def set_worlds
    @worlds = Worlds.find(params[:id])
  end

  def worlds_params
    params.require(:worlds).permit()
  end

end