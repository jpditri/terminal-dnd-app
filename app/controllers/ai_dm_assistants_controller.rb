# frozen_string_literal: true

class AiDmAssistantsController < ApplicationController
  before_action :require_authentication
  before_action :set_campaign
  before_action :ensure_user_is_dm
  before_action :set_ai_dm_assistant, only: [:show, :update, :destroy, :pause, :resume, :toggle_suggestion_type, :statistics]

  def show
    authorize @ai_dm_assistants
  end

  def create
    @ai_dm_assistants = AiDmAssistants.new(ai_dm_assistants_params)
    authorize @ai_dm_assistants

    respond_to do |format|
      if @ai_dm_assistants.save
        format.html { redirect_to @ai_dm_assistants, notice: 'AiDmAssistants was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @ai_dm_assistants

    respond_to do |format|
      if @ai_dm_assistants.update(ai_dm_assistants_params)
        format.html { redirect_to @ai_dm_assistants, notice: 'AiDmAssistants was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @ai_dm_assistants

    @ai_dm_assistants.destroy

    respond_to do |format|
      format.html { redirect_to ai_dm_assistantses_path, notice: 'AiDmAssistants was successfully deleted.' }
      format.turbo_stream
    end
  end

  def pause
    # TODO: Implement pause
  end

  def resume
    # TODO: Implement resume
  end

  def toggle_suggestion_type
    # TODO: Implement toggle_suggestion_type
  end

  def statistics
    # TODO: Implement statistics
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_campaign
    # TODO: Implement set_campaign
  end

  def ensure_user_is_dm
    # TODO: Implement ensure_user_is_dm
  end

  def set_ai_dm_assistant
    # TODO: Implement set_ai_dm_assistant
  end

  private

  def set_ai_dm_assistants
    @ai_dm_assistants = AiDmAssistants.find(params[:id])
  end

  def ai_dm_assistants_params
    params.require(:ai_dm_assistants).permit()
  end

end