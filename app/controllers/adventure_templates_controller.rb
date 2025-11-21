# frozen_string_literal: true

class AdventureTemplatesController < ApplicationController
  before_action :require_authentication, only: [:index, :show, :library]
  before_action :set_adventure_template

  def index
    @adventure_templateses = policy_scope(AdventureTemplates)
    @adventure_templateses = @adventure_templateses.search(params[:q]) if params[:q].present?
    @adventure_templateses = @adventure_templateses.page(params[:page]).per(20)
  end

  def show
    authorize @adventure_templates
  end

  def new
    @adventure_templates = AdventureTemplates.new
    authorize @adventure_templates
  end

  def edit
    authorize @adventure_templates
  end

  def create
    @adventure_templates = AdventureTemplates.new(adventure_templates_params)
    authorize @adventure_templates

    respond_to do |format|
      if @adventure_templates.save
        format.html { redirect_to @adventure_templates, notice: 'AdventureTemplates was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @adventure_templates

    respond_to do |format|
      if @adventure_templates.update(adventure_templates_params)
        format.html { redirect_to @adventure_templates, notice: 'AdventureTemplates was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @adventure_templates

    @adventure_templates.destroy

    respond_to do |format|
      format.html { redirect_to adventure_templateses_path, notice: 'AdventureTemplates was successfully deleted.' }
      format.turbo_stream
    end
  end

  def library
    # TODO: Implement library
  end

  def preview
    # TODO: Implement preview
  end

  def publish
    # TODO: Implement publish
  end

  def archive
    # TODO: Implement archive
  end

  def instantiate
    # TODO: Implement instantiate
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_adventure_template
    # TODO: Implement set_adventure_template
  end

  private

  def set_adventure_templates
    @adventure_templates = AdventureTemplates.find(params[:id])
  end

  def adventure_templates_params
    params.require(:adventure_templates).permit()
  end

end