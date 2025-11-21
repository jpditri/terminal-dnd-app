# frozen_string_literal: true

module CharacterFeatures
  module Inventory
    class InventoriesController < ApplicationController
      before_action :set_character
      before_action :authorize_character
      before_action :set_inventory

      def show
        authorize @character_features::inventory::inventories
      end

      def add_item
        # TODO: Implement add_item
      end

      def move_item
        # TODO: Implement move_item
      end

      def remove_item
        # TODO: Implement remove_item
      end

      def equip_item
        # TODO: Implement equip_item
      end

      def unequip_item
        # TODO: Implement unequip_item
      end

      def save_equipment_set
        # TODO: Implement save_equipment_set
      end

      def load_equipment_set
        # TODO: Implement load_equipment_set
      end

      def convert_currency
        # TODO: Implement convert_currency
      end

      def attune_item
        # TODO: Implement attune_item
      end

      def identify_item
        # TODO: Implement identify_item
      end

      def search
        # TODO: Implement search
      end

      def set_character
        # TODO: Implement set_character
      end

      def authorize_character
        # TODO: Implement authorize_character
      end

      def set_inventory
        # TODO: Implement set_inventory
      end

      private

      def set_character_features::inventory::inventories
        @character_features::inventory::inventories = CharacterFeatures::inventory::inventories.find(params[:id])
      end

      def character_features::inventory::inventories_params
        params.require(:character_features::inventory::inventories).permit()
      end

    end
  end
end