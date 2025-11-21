# frozen_string_literal: true

class AiDmSuggestionsController < ApplicationController
  before_action :require_authentication
  before_action :set_campaign
  before_action :set_ai_dm_assistant
  before_action :ensure_assistant_active, only: [:create]
  before_action :set_suggestion, only: [:show, :accept, :reject, :edit]

  def index
    @ai_dm_suggestionses = policy_scope(AiDmSuggestions)
    @ai_dm_suggestionses = @ai_dm_suggestionses.search(params[:q]) if params[:q].present?
    @ai_dm_suggestionses = @ai_dm_suggestionses.page(params[:page]).per(20)
  end

  def create
    @ai_dm_suggestions = AiDmSuggestions.new(ai_dm_suggestions_params)
    authorize @ai_dm_suggestions

    respond_to do |format|
      if @ai_dm_suggestions.save
        format.html { redirect_to @ai_dm_suggestions, notice: 'AiDmSuggestions was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def show
    authorize @ai_dm_suggestions
  end

  def edit
    authorize @ai_dm_suggestions
  end

  def accept
    # TODO: Implement accept
  end

  def reject
    # TODO: Implement reject
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_campaign
    # TODO: Implement set_campaign
  end

  def set_ai_dm_assistant
    # TODO: Implement set_ai_dm_assistant
  end

  def ensure_assistant_active
    # TODO: Implement ensure_assistant_active
  end

  def set_suggestion
    # TODO: Implement set_suggestion
  end

  private

  def set_ai_dm_suggestions
    @ai_dm_suggestions = AiDmSuggestions.find(params[:id])
  end

  def ai_dm_suggestions_params
    params.require(:ai_dm_suggestions).permit()
  end

end