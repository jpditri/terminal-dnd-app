# frozen_string_literal: true

module Campaigns
  class BulkOperationsController < ApplicationController
    before_action :require_authentication
    before_action :set_campaign, only: [:export_campaign, :print_party, :import_campaign]
    before_action :set_archive, only: [:status, :download]

    def index
      @campaigns::bulk_operationses = policy_scope(Campaigns::bulkOperations)
      @campaigns::bulk_operationses = @campaigns::bulk_operationses.search(params[:q]) if params[:q].present?
      @campaigns::bulk_operationses = @campaigns::bulk_operationses.page(params[:page]).per(20)
    end

    def export_campaign
      # TODO: Implement export_campaign
    end

    def print_party
      # TODO: Implement print_party
    end

    def import_campaign
      # TODO: Implement import_campaign
    end

    def status
      # TODO: Implement status
    end

    def download
      # TODO: Implement download
    end

    def require_authentication
      # TODO: Implement require_authentication
    end

    def set_campaign
      # TODO: Implement set_campaign
    end

    def set_archive
      # TODO: Implement set_archive
    end

    private

    def set_campaigns::bulk_operations
      @campaigns::bulk_operations = Campaigns::bulkOperations.find(params[:id])
    end

    def campaigns::bulk_operations_params
      params.require(:campaigns::bulk_operations).permit()
    end

  end
end