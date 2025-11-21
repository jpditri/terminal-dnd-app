# frozen_string_literal: true

class QuestLogsController < ApplicationController
  before_action :require_authentication
  before_action :set_quest_log

  def index
    @quest_logses = policy_scope(QuestLogs)
    @quest_logses = @quest_logses.search(params[:q]) if params[:q].present?
    @quest_logses = @quest_logses.page(params[:page]).per(20)
  end

  def show
    authorize @quest_logs
  end

  def new
    @quest_logs = QuestLogs.new
    authorize @quest_logs
  end

  def edit
    authorize @quest_logs
  end

  def create
    @quest_logs = QuestLogs.new(quest_logs_params)
    authorize @quest_logs

    respond_to do |format|
      if @quest_logs.save
        format.html { redirect_to @quest_logs, notice: 'QuestLogs was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @quest_logs

    respond_to do |format|
      if @quest_logs.update(quest_logs_params)
        format.html { redirect_to @quest_logs, notice: 'QuestLogs was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @quest_logs

    @quest_logs.destroy

    respond_to do |format|
      format.html { redirect_to quest_logses_path, notice: 'QuestLogs was successfully deleted.' }
      format.turbo_stream
    end
  end

  def complete
    # TODO: Implement complete
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_quest_log
    # TODO: Implement set_quest_log
  end

  private

  def set_quest_logs
    @quest_logs = QuestLogs.find(params[:id])
  end

  def quest_logs_params
    params.require(:quest_logs).permit()
  end

end