# frozen_string_literal: true

module Roleplay
  class CampaignDiscoveryService
    attr_reader :current_user

    def initialize(current_user: CurrentUser.new)
      @current_user = current_user
    end


    def search
      # TODO: Implement
    end

    def filter_options
      # TODO: Implement
    end
  end
end