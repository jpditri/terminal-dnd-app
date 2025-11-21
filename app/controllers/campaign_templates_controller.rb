# frozen_string_literal: true

class CampaignTemplatesController < ApplicationController
  before_action :set_user
  before_action :set_campaign_template, only: [:show, :edit, :update, :destroy, :use_template]

  def index
    @campaign_templateses = policy_scope(CampaignTemplates)
    @campaign_templateses = @campaign_templateses.search(params[:q]) if params[:q].present?
    @campaign_templateses = @campaign_templateses.page(params[:page]).per(20)
  end

  def show
    authorize @campaign_templates
  end

  def new
    @campaign_templates = CampaignTemplates.new
    authorize @campaign_templates
  end

  def create
    @campaign_templates = CampaignTemplates.new(campaign_templates_params)
    authorize @campaign_templates

    respond_to do |format|
      if @campaign_templates.save
        format.html { redirect_to @campaign_templates, notice: 'CampaignTemplates was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @campaign_templates
  end

  def update
    authorize @campaign_templates

    respond_to do |format|
      if @campaign_templates.update(campaign_templates_params)
        format.html { redirect_to @campaign_templates, notice: 'CampaignTemplates was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @campaign_templates

    @campaign_templates.destroy

    respond_to do |format|
      format.html { redirect_to campaign_templateses_path, notice: 'CampaignTemplates was successfully deleted.' }
      format.turbo_stream
    end
  end

  def use_template
    # TODO: Implement use_template
  end

  def my_templates
    # TODO: Implement my_templates
  end

  def set_user
    # TODO: Implement set_user
  end

  def set_campaign_template
    # TODO: Implement set_campaign_template
  end

  private

  def set_campaign_templates
    @campaign_templates = CampaignTemplates.find(params[:id])
  end

  def campaign_templates_params
    params.require(:campaign_templates).permit()
  end

end