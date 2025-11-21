# frozen_string_literal: true

class CombatActionsController < ApplicationController
  before_action :require_authentication
  before_action :set_combat_action

  def index
    @combat_actionses = policy_scope(CombatActions)
    @combat_actionses = @combat_actionses.search(params[:q]) if params[:q].present?
    @combat_actionses = @combat_actionses.page(params[:page]).per(20)
  end

  def show
    authorize @combat_actions
  end

  def new
    @combat_actions = CombatActions.new
    authorize @combat_actions
  end

  def edit
    authorize @combat_actions
  end

  def create
    @combat_actions = CombatActions.new(combat_actions_params)
    authorize @combat_actions

    respond_to do |format|
      if @combat_actions.save
        format.html { redirect_to @combat_actions, notice: 'CombatActions was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @combat_actions

    respond_to do |format|
      if @combat_actions.update(combat_actions_params)
        format.html { redirect_to @combat_actions, notice: 'CombatActions was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @combat_actions

    @combat_actions.destroy

    respond_to do |format|
      format.html { redirect_to combat_actionses_path, notice: 'CombatActions was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_combat_action
    # TODO: Implement set_combat_action
  end

  private

  def set_combat_actions
    @combat_actions = CombatActions.find(params[:id])
  end

  def combat_actions_params
    params.require(:combat_actions).permit()
  end

end