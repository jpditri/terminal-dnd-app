# frozen_string_literal: true

class BackgroundsController < ApplicationController
  before_action :set_background

  def index
    @backgroundses = policy_scope(Backgrounds)
    @backgroundses = @backgroundses.search(params[:q]) if params[:q].present?
    @backgroundses = @backgroundses.page(params[:page]).per(20)
  end

  def show
    authorize @backgrounds
  end

  def edit
    authorize @backgrounds
  end

  def new
    @backgrounds = Backgrounds.new
    authorize @backgrounds
  end

  def create
    @backgrounds = Backgrounds.new(backgrounds_params)
    authorize @backgrounds

    respond_to do |format|
      if @backgrounds.save
        format.html { redirect_to @backgrounds, notice: 'Backgrounds was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @backgrounds

    respond_to do |format|
      if @backgrounds.update(backgrounds_params)
        format.html { redirect_to @backgrounds, notice: 'Backgrounds was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @backgrounds

    @backgrounds.destroy

    respond_to do |format|
      format.html { redirect_to backgroundses_path, notice: 'Backgrounds was successfully deleted.' }
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

  def set_background
    # TODO: Implement set_background
  end

  private

  def set_backgrounds
    @backgrounds = Backgrounds.find(params[:id])
  end

  def backgrounds_params
    params.require(:backgrounds).permit()
  end

end