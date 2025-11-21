# frozen_string_literal: true

class CharacterClassesController < ApplicationController
  before_action :set_character_class

  def index
    @character_classeses = policy_scope(CharacterClasses)
    @character_classeses = @character_classeses.search(params[:q]) if params[:q].present?
    @character_classeses = @character_classeses.page(params[:page]).per(20)
  end

  def show
    authorize @character_classes
  end

  def edit
    authorize @character_classes
  end

  def new
    @character_classes = CharacterClasses.new
    authorize @character_classes
  end

  def create
    @character_classes = CharacterClasses.new(character_classes_params)
    authorize @character_classes

    respond_to do |format|
      if @character_classes.save
        format.html { redirect_to @character_classes, notice: 'CharacterClasses was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @character_classes

    respond_to do |format|
      if @character_classes.update(character_classes_params)
        format.html { redirect_to @character_classes, notice: 'CharacterClasses was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @character_classes

    @character_classes.destroy

    respond_to do |format|
      format.html { redirect_to character_classeses_path, notice: 'CharacterClasses was successfully deleted.' }
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

  def set_character_class
    # TODO: Implement set_character_class
  end

  private

  def set_character_classes
    @character_classes = CharacterClasses.find(params[:id])
  end

  def character_classes_params
    params.require(:character_classes).permit()
  end

end