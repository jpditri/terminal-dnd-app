# frozen_string_literal: true

class AiMessagesController < ApplicationController
  before_action :require_authentication
  before_action :set_ai_message

  def index
    @ai_messageses = policy_scope(AiMessages)
    @ai_messageses = @ai_messageses.search(params[:q]) if params[:q].present?
    @ai_messageses = @ai_messageses.page(params[:page]).per(20)
  end

  def show
    authorize @ai_messages
  end

  def new
    @ai_messages = AiMessages.new
    authorize @ai_messages
  end

  def edit
    authorize @ai_messages
  end

  def create
    @ai_messages = AiMessages.new(ai_messages_params)
    authorize @ai_messages

    respond_to do |format|
      if @ai_messages.save
        format.html { redirect_to @ai_messages, notice: 'AiMessages was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @ai_messages

    respond_to do |format|
      if @ai_messages.update(ai_messages_params)
        format.html { redirect_to @ai_messages, notice: 'AiMessages was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @ai_messages

    @ai_messages.destroy

    respond_to do |format|
      format.html { redirect_to ai_messageses_path, notice: 'AiMessages was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_ai_message
    # TODO: Implement set_ai_message
  end

  private

  def set_ai_messages
    @ai_messages = AiMessages.find(params[:id])
  end

  def ai_messages_params
    params.require(:ai_messages).permit()
  end

end