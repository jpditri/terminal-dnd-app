# frozen_string_literal: true

class LootTablesController < ApplicationController
  before_action :set_loot_table, only: [:show, :edit, :update, :destroy, :generate, :test_roll]

  def index
    @loot_tableses = policy_scope(LootTables)
    @loot_tableses = @loot_tableses.search(params[:q]) if params[:q].present?
    @loot_tableses = @loot_tableses.page(params[:page]).per(20)
  end

  def show
    authorize @loot_tables
  end

  def new
    @loot_tables = LootTables.new
    authorize @loot_tables
  end

  def edit
    authorize @loot_tables
  end

  def create
    @loot_tables = LootTables.new(loot_tables_params)
    authorize @loot_tables

    respond_to do |format|
      if @loot_tables.save
        format.html { redirect_to @loot_tables, notice: 'LootTables was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @loot_tables

    respond_to do |format|
      if @loot_tables.update(loot_tables_params)
        format.html { redirect_to @loot_tables, notice: 'LootTables was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @loot_tables

    @loot_tables.destroy

    respond_to do |format|
      format.html { redirect_to loot_tableses_path, notice: 'LootTables was successfully deleted.' }
      format.turbo_stream
    end
  end

  def library
    # TODO: Implement library
  end

  def generate
    # TODO: Implement generate
  end

  def test_roll
    # TODO: Implement test_roll
  end

  def set_loot_table
    # TODO: Implement set_loot_table
  end

  private

  def set_loot_tables
    @loot_tables = LootTables.find(params[:id])
  end

  def loot_tables_params
    params.require(:loot_tables).permit()
  end

end