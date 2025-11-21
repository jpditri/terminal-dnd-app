# frozen_string_literal: true

class EncounterMonstersController < ApplicationController
  before_action :require_authentication
  before_action :set_encounter_monster

  def index
    @encounter_monsterses = policy_scope(EncounterMonsters)
    @encounter_monsterses = @encounter_monsterses.search(params[:q]) if params[:q].present?
    @encounter_monsterses = @encounter_monsterses.page(params[:page]).per(20)
  end

  def show
    authorize @encounter_monsters
  end

  def new
    @encounter_monsters = EncounterMonsters.new
    authorize @encounter_monsters
  end

  def edit
    authorize @encounter_monsters
  end

  def create
    @encounter_monsters = EncounterMonsters.new(encounter_monsters_params)
    authorize @encounter_monsters

    respond_to do |format|
      if @encounter_monsters.save
        format.html { redirect_to @encounter_monsters, notice: 'EncounterMonsters was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @encounter_monsters

    respond_to do |format|
      if @encounter_monsters.update(encounter_monsters_params)
        format.html { redirect_to @encounter_monsters, notice: 'EncounterMonsters was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @encounter_monsters

    @encounter_monsters.destroy

    respond_to do |format|
      format.html { redirect_to encounter_monsterses_path, notice: 'EncounterMonsters was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_encounter_monster
    # TODO: Implement set_encounter_monster
  end

  private

  def set_encounter_monsters
    @encounter_monsters = EncounterMonsters.find(params[:id])
  end

  def encounter_monsters_params
    params.require(:encounter_monsters).permit()
  end

end