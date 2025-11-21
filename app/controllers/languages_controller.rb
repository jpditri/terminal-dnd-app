# frozen_string_literal: true

class LanguagesController < ApplicationController
  before_action :set_language

  def index
    @languageses = policy_scope(Languages)
    @languageses = @languageses.search(params[:q]) if params[:q].present?
    @languageses = @languageses.page(params[:page]).per(20)
  end

  def show
    authorize @languages
  end

  def edit
    authorize @languages
  end

  def new
    @languages = Languages.new
    authorize @languages
  end

  def create
    @languages = Languages.new(languages_params)
    authorize @languages

    respond_to do |format|
      if @languages.save
        format.html { redirect_to @languages, notice: 'Languages was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @languages

    respond_to do |format|
      if @languages.update(languages_params)
        format.html { redirect_to @languages, notice: 'Languages was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @languages

    @languages.destroy

    respond_to do |format|
      format.html { redirect_to languageses_path, notice: 'Languages was successfully deleted.' }
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

  def set_language
    # TODO: Implement set_language
  end

  private

  def set_languages
    @languages = Languages.find(params[:id])
  end

  def languages_params
    params.require(:languages).permit()
  end

end