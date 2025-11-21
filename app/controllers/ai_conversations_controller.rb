# frozen_string_literal: true

class AiConversationsController < ApplicationController
  before_action :require_authentication
  before_action :set_ai_conversation

  def index
    @ai_conversationses = policy_scope(AiConversations)
    @ai_conversationses = @ai_conversationses.search(params[:q]) if params[:q].present?
    @ai_conversationses = @ai_conversationses.page(params[:page]).per(20)
  end

  def show
    authorize @ai_conversations
  end

  def new
    @ai_conversations = AiConversations.new
    authorize @ai_conversations
  end

  def edit
    authorize @ai_conversations
  end

  def create
    @ai_conversations = AiConversations.new(ai_conversations_params)
    authorize @ai_conversations

    respond_to do |format|
      if @ai_conversations.save
        format.html { redirect_to @ai_conversations, notice: 'AiConversations was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @ai_conversations

    respond_to do |format|
      if @ai_conversations.update(ai_conversations_params)
        format.html { redirect_to @ai_conversations, notice: 'AiConversations was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @ai_conversations

    @ai_conversations.destroy

    respond_to do |format|
      format.html { redirect_to ai_conversationses_path, notice: 'AiConversations was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_ai_conversation
    # TODO: Implement set_ai_conversation
  end

  private

  def set_ai_conversations
    @ai_conversations = AiConversations.find(params[:id])
  end

  def ai_conversations_params
    params.require(:ai_conversations).permit()
  end

end