# frozen_string_literal: true

class QuestObjectivesController < ApplicationController
  before_action :require_authentication
  before_action :set_quest_objective

  def index
    @quest_objectiveses = policy_scope(QuestObjectives)
    @quest_objectiveses = @quest_objectiveses.search(params[:q]) if params[:q].present?
    @quest_objectiveses = @quest_objectiveses.page(params[:page]).per(20)
  end

  def show
    authorize @quest_objectives
  end

  def new
    @quest_objectives = QuestObjectives.new
    authorize @quest_objectives
  end

  def edit
    authorize @quest_objectives
  end

  def create
    @quest_objectives = QuestObjectives.new(quest_objectives_params)
    authorize @quest_objectives

    respond_to do |format|
      if @quest_objectives.save
        format.html { redirect_to @quest_objectives, notice: 'QuestObjectives was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @quest_objectives

    respond_to do |format|
      if @quest_objectives.update(quest_objectives_params)
        format.html { redirect_to @quest_objectives, notice: 'QuestObjectives was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @quest_objectives

    @quest_objectives.destroy

    respond_to do |format|
      format.html { redirect_to quest_objectiveses_path, notice: 'QuestObjectives was successfully deleted.' }
      format.turbo_stream
    end
  end

  def toggle_complete
    # TODO: Implement toggle_complete
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_quest_objective
    # TODO: Implement set_quest_objective
  end

  private

  def set_quest_objectives
    @quest_objectives = QuestObjectives.find(params[:id])
  end

  def quest_objectives_params
    params.require(:quest_objectives).permit()
  end

end