# frozen_string_literal: true

class ConditionsController < ApplicationController
  before_action :set_condition

  def index
    @conditionses = policy_scope(Conditions)
    @conditionses = @conditionses.search(params[:q]) if params[:q].present?
    @conditionses = @conditionses.page(params[:page]).per(20)
  end

  def show
    authorize @conditions
  end

  def edit
    authorize @conditions
  end

  def new
    @conditions = Conditions.new
    authorize @conditions
  end

  def create
    @conditions = Conditions.new(conditions_params)
    authorize @conditions

    respond_to do |format|
      if @conditions.save
        format.html { redirect_to @conditions, notice: 'Conditions was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @conditions

    respond_to do |format|
      if @conditions.update(conditions_params)
        format.html { redirect_to @conditions, notice: 'Conditions was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @conditions

    @conditions.destroy

    respond_to do |format|
      format.html { redirect_to conditionses_path, notice: 'Conditions was successfully deleted.' }
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

  def set_condition
    # TODO: Implement set_condition
  end

  private

  def set_conditions
    @conditions = Conditions.find(params[:id])
  end

  def conditions_params
    params.require(:conditions).permit()
  end

end