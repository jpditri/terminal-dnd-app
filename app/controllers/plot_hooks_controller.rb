# frozen_string_literal: true

class PlotHooksController < ApplicationController
  before_action :require_authentication
  before_action :set_plot_hook

  def index
    @plot_hookses = policy_scope(PlotHooks)
    @plot_hookses = @plot_hookses.search(params[:q]) if params[:q].present?
    @plot_hookses = @plot_hookses.page(params[:page]).per(20)
  end

  def show
    authorize @plot_hooks
  end

  def new
    @plot_hooks = PlotHooks.new
    authorize @plot_hooks
  end

  def create
    @plot_hooks = PlotHooks.new(plot_hooks_params)
    authorize @plot_hooks

    respond_to do |format|
      if @plot_hooks.save
        format.html { redirect_to @plot_hooks, notice: 'PlotHooks was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @plot_hooks

    respond_to do |format|
      if @plot_hooks.update(plot_hooks_params)
        format.html { redirect_to @plot_hooks, notice: 'PlotHooks was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @plot_hooks

    @plot_hooks.destroy

    respond_to do |format|
      format.html { redirect_to plot_hookses_path, notice: 'PlotHooks was successfully deleted.' }
      format.turbo_stream
    end
  end

  def restore
    # TODO: Implement restore
  end

  def convert_to_quest
    # TODO: Implement convert_to_quest
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_plot_hook
    # TODO: Implement set_plot_hook
  end

  private

  def set_plot_hooks
    @plot_hooks = PlotHooks.find(params[:id])
  end

  def plot_hooks_params
    params.require(:plot_hooks).permit()
  end

end