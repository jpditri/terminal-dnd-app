# frozen_string_literal: true

class DungeonTemplatesController < ApplicationController
  before_action :require_authentication
  before_action :set_dungeon_template

  def index
    @dungeon_templateses = policy_scope(DungeonTemplates)
    @dungeon_templateses = @dungeon_templateses.search(params[:q]) if params[:q].present?
    @dungeon_templateses = @dungeon_templateses.page(params[:page]).per(20)
  end

  def show
    authorize @dungeon_templates
  end

  def new
    @dungeon_templates = DungeonTemplates.new
    authorize @dungeon_templates
  end

  def create
    @dungeon_templates = DungeonTemplates.new(dungeon_templates_params)
    authorize @dungeon_templates

    respond_to do |format|
      if @dungeon_templates.save
        format.html { redirect_to @dungeon_templates, notice: 'DungeonTemplates was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @dungeon_templates

    respond_to do |format|
      if @dungeon_templates.update(dungeon_templates_params)
        format.html { redirect_to @dungeon_templates, notice: 'DungeonTemplates was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @dungeon_templates

    @dungeon_templates.destroy

    respond_to do |format|
      format.html { redirect_to dungeon_templateses_path, notice: 'DungeonTemplates was successfully deleted.' }
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

  def set_dungeon_template
    # TODO: Implement set_dungeon_template
  end

  private

  def set_dungeon_templates
    @dungeon_templates = DungeonTemplates.find(params[:id])
  end

  def dungeon_templates_params
    params.require(:dungeon_templates).permit()
  end

end