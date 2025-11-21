# frozen_string_literal: true

module Campaigns
  class QuestsController < ApplicationController
    before_action :set_campaign
    before_action :set_quest, only: [:show, :edit, :update, :destroy, :complete, :update_priority]

    def index
      @campaigns::questses = policy_scope(Campaigns::quests)
      @campaigns::questses = @campaigns::questses.search(params[:q]) if params[:q].present?
      @campaigns::questses = @campaigns::questses.page(params[:page]).per(20)
    end

    def show
      authorize @campaigns::quests
    end

    def new
      @campaigns::quests = Campaigns::quests.new
      authorize @campaigns::quests
    end

    def create
      @campaigns::quests = Campaigns::quests.new(campaigns::quests_params)
      authorize @campaigns::quests

      respond_to do |format|
        if @campaigns::quests.save
          format.html { redirect_to @campaigns::quests, notice: 'Campaigns::quests was successfully created.' }
          format.turbo_stream
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      authorize @campaigns::quests

      respond_to do |format|
        if @campaigns::quests.update(campaigns::quests_params)
          format.html { redirect_to @campaigns::quests, notice: 'Campaigns::quests was successfully updated.' }
          format.turbo_stream
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @campaigns::quests

      @campaigns::quests.destroy

      respond_to do |format|
        format.html { redirect_to campaigns::questses_path, notice: 'Campaigns::quests was successfully deleted.' }
        format.turbo_stream
      end
    end

    def create_from_template
      # TODO: Implement create_from_template
    end

    def update_priority
      # TODO: Implement update_priority
    end

    def bulk_update_priorities
      # TODO: Implement bulk_update_priorities
    end

    def complete
      # TODO: Implement complete
    end

    def chain_visualization
      # TODO: Implement chain_visualization
    end

    def calculate_rewards
      # TODO: Implement calculate_rewards
    end

    def set_campaign
      # TODO: Implement set_campaign
    end

    def set_quest
      # TODO: Implement set_quest
    end

    private

    def set_campaigns::quests
      @campaigns::quests = Campaigns::quests.find(params[:id])
    end

    def campaigns::quests_params
      params.require(:campaigns::quests).permit()
    end

  end
end