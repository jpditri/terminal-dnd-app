# frozen_string_literal: true

class EncounterTemplatesController < ApplicationController
  before_action :require_authentication
  before_action :set_encounter_template

  def index
    @encounter_templateses = policy_scope(EncounterTemplates)
    @encounter_templateses = @encounter_templateses.search(params[:q]) if params[:q].present?
    @encounter_templateses = @encounter_templateses.page(params[:page]).per(20)
  end

  def show
    authorize @encounter_templates
  end

  def new
    @encounter_templates = EncounterTemplates.new
    authorize @encounter_templates
  end

  def create
    @encounter_templates = EncounterTemplates.new(encounter_templates_params)
    authorize @encounter_templates

    respond_to do |format|
      if @encounter_templates.save
        format.html { redirect_to @encounter_templates, notice: 'EncounterTemplates was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @encounter_templates

    respond_to do |format|
      if @encounter_templates.update(encounter_templates_params)
        format.html { redirect_to @encounter_templates, notice: 'EncounterTemplates was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @encounter_templates

    @encounter_templates.destroy

    respond_to do |format|
      format.html { redirect_to encounter_templateses_path, notice: 'EncounterTemplates was successfully deleted.' }
      format.turbo_stream
    end
  end

  def restore
    # TODO: Implement restore
  end

  def generate
    # TODO: Implement generate
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_encounter_template
    # TODO: Implement set_encounter_template
  end

  private

  def set_encounter_templates
    @encounter_templates = EncounterTemplates.find(params[:id])
  end

  def encounter_templates_params
    params.require(:encounter_templates).permit()
  end

end