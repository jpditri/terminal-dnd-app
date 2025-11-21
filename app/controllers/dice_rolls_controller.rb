# frozen_string_literal: true

class DiceRollsController < ApplicationController
  before_action :require_authentication
  before_action :set_dice_roll

  def index
    @dice_rollses = policy_scope(DiceRolls)
    @dice_rollses = @dice_rollses.search(params[:q]) if params[:q].present?
    @dice_rollses = @dice_rollses.page(params[:page]).per(20)
  end

  def show
    authorize @dice_rolls
  end

  def new
    @dice_rolls = DiceRolls.new
    authorize @dice_rolls
  end

  def edit
    authorize @dice_rolls
  end

  def create
    @dice_rolls = DiceRolls.new(dice_rolls_params)
    authorize @dice_rolls

    respond_to do |format|
      if @dice_rolls.save
        format.html { redirect_to @dice_rolls, notice: 'DiceRolls was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @dice_rolls

    respond_to do |format|
      if @dice_rolls.update(dice_rolls_params)
        format.html { redirect_to @dice_rolls, notice: 'DiceRolls was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @dice_rolls

    @dice_rolls.destroy

    respond_to do |format|
      format.html { redirect_to dice_rollses_path, notice: 'DiceRolls was successfully deleted.' }
      format.turbo_stream
    end
  end

  def request_reroll
    # TODO: Implement request_reroll
  end

  def approve_reroll
    # TODO: Implement approve_reroll
  end

  def deny_reroll
    # TODO: Implement deny_reroll
  end

  def execute_reroll
    # TODO: Implement execute_reroll
  end

  def chain
    # TODO: Implement chain
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_dice_roll
    # TODO: Implement set_dice_roll
  end

  private

  def set_dice_rolls
    @dice_rolls = DiceRolls.find(params[:id])
  end

  def dice_rolls_params
    params.require(:dice_rolls).permit()
  end

end