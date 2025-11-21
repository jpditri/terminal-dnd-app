# frozen_string_literal: true

class MonsterAbilitiesController < ApplicationController
  before_action :require_authentication
  before_action :set_monster_ability

  def index
    @monster_abilitieses = policy_scope(MonsterAbilities)
    @monster_abilitieses = @monster_abilitieses.search(params[:q]) if params[:q].present?
    @monster_abilitieses = @monster_abilitieses.page(params[:page]).per(20)
  end

  def show
    authorize @monster_abilities
  end

  def edit
    authorize @monster_abilities
  end

  def new
    @monster_abilities = MonsterAbilities.new
    authorize @monster_abilities
  end

  def create
    @monster_abilities = MonsterAbilities.new(monster_abilities_params)
    authorize @monster_abilities

    respond_to do |format|
      if @monster_abilities.save
        format.html { redirect_to @monster_abilities, notice: 'MonsterAbilities was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @monster_abilities

    respond_to do |format|
      if @monster_abilities.update(monster_abilities_params)
        format.html { redirect_to @monster_abilities, notice: 'MonsterAbilities was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @monster_abilities

    @monster_abilities.destroy

    respond_to do |format|
      format.html { redirect_to monster_abilitieses_path, notice: 'MonsterAbilities was successfully deleted.' }
      format.turbo_stream
    end
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

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_monster_ability
    # TODO: Implement set_monster_ability
  end

  private

  def set_monster_abilities
    @monster_abilities = MonsterAbilities.find(params[:id])
  end

  def monster_abilities_params
    params.require(:monster_abilities).permit()
  end

end