# frozen_string_literal: true

class MonstersController < ApplicationController
  before_action :set_monster

  def index
    @monsterses = policy_scope(Monsters)
    @monsterses = @monsterses.search(params[:q]) if params[:q].present?
    @monsterses = @monsterses.page(params[:page]).per(20)
  end

  def show
    authorize @monsters
  end

  def edit
    authorize @monsters
  end

  def new
    @monsters = Monsters.new
    authorize @monsters
  end

  def create
    @monsters = Monsters.new(monsters_params)
    authorize @monsters

    respond_to do |format|
      if @monsters.save
        format.html { redirect_to @monsters, notice: 'Monsters was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @monsters

    respond_to do |format|
      if @monsters.update(monsters_params)
        format.html { redirect_to @monsters, notice: 'Monsters was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @monsters

    @monsters.destroy

    respond_to do |format|
      format.html { redirect_to monsterses_path, notice: 'Monsters was successfully deleted.' }
      format.turbo_stream
    end
  end

  def search
    # TODO: Implement search
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

  def set_monster
    # TODO: Implement set_monster
  end

  private

  def set_monsters
    @monsters = Monsters.find(params[:id])
  end

  def monsters_params
    params.require(:monsters).permit()
  end

end