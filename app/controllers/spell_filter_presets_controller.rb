# frozen_string_literal: true

class SpellFilterPresetsController < ApplicationController
  before_action :set_preset
  before_action :authorize_preset
  before_action :verify_authenticity_token, only: [:sync]

  def index
    @spell_filter_presetses = policy_scope(SpellFilterPresets)
    @spell_filter_presetses = @spell_filter_presetses.search(params[:q]) if params[:q].present?
    @spell_filter_presetses = @spell_filter_presetses.page(params[:page]).per(20)
  end

  def show
    authorize @spell_filter_presets
  end

  def new
    @spell_filter_presets = SpellFilterPresets.new
    authorize @spell_filter_presets
  end

  def edit
    authorize @spell_filter_presets
  end

  def create
    @spell_filter_presets = SpellFilterPresets.new(spell_filter_presets_params)
    authorize @spell_filter_presets

    respond_to do |format|
      if @spell_filter_presets.save
        format.html { redirect_to @spell_filter_presets, notice: 'SpellFilterPresets was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @spell_filter_presets

    respond_to do |format|
      if @spell_filter_presets.update(spell_filter_presets_params)
        format.html { redirect_to @spell_filter_presets, notice: 'SpellFilterPresets was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @spell_filter_presets

    @spell_filter_presets.destroy

    respond_to do |format|
      format.html { redirect_to spell_filter_presetses_path, notice: 'SpellFilterPresets was successfully deleted.' }
      format.turbo_stream
    end
  end

  def increment_usage
    # TODO: Implement increment_usage
  end

  def share
    # TODO: Implement share
  end

  def export
    # TODO: Implement export
  end

  def import
    # TODO: Implement import
  end

  def sync
    # TODO: Implement sync
  end

  def from_url
    # TODO: Implement from_url
  end

  def set_preset
    # TODO: Implement set_preset
  end

  def authorize_preset
    # TODO: Implement authorize_preset
  end

  def verify_authenticity_token
    # TODO: Implement verify_authenticity_token
  end

  private

  def set_spell_filter_presets
    @spell_filter_presets = SpellFilterPresets.find(params[:id])
  end

  def spell_filter_presets_params
    params.require(:spell_filter_presets).permit()
  end

end