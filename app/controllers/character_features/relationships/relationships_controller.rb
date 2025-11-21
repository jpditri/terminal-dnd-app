# frozen_string_literal: true

module CharacterFeatures
  module Relationships
    class RelationshipsController < ApplicationController
      before_action :set_character, except: [:party_view, :party_inventory, :party_statistics, :assign_role, :create_party_goal, :update_goal_progress, :unlock_achievement, :cast_vote]
      before_action :set_campaign, only: [:party_view, :party_inventory, :party_statistics, :assign_role, :create_party_goal, :unlock_achievement]

      def index
        @character_features::relationships::relationshipses = policy_scope(CharacterFeatures::relationships::relationships)
        @character_features::relationships::relationshipses = @character_features::relationships::relationshipses.search(params[:q]) if params[:q].present?
        @character_features::relationships::relationshipses = @character_features::relationships::relationshipses.page(params[:page]).per(20)
      end

      def show
        authorize @character_features::relationships::relationships
      end

      def party_view
        # TODO: Implement party_view
      end

      def create_bond
        # TODO: Implement create_bond
      end

      def update_bond
        # TODO: Implement update_bond
      end

      def shared_backstory
        # TODO: Implement shared_backstory
      end

      def approve_proposal
        # TODO: Implement approve_proposal
      end

      def assign_role
        # TODO: Implement assign_role
      end

      def cast_vote
        # TODO: Implement cast_vote
      end

      def party_inventory
        # TODO: Implement party_inventory
      end

      def request_item
        # TODO: Implement request_item
      end

      def create_party_goal
        # TODO: Implement create_party_goal
      end

      def update_goal_progress
        # TODO: Implement update_goal_progress
      end

      def npc_relationships
        # TODO: Implement npc_relationships
      end

      def unlock_achievement
        # TODO: Implement unlock_achievement
      end

      def add_relationship_note
        # TODO: Implement add_relationship_note
      end

      def adjust_bond
        # TODO: Implement adjust_bond
      end

      def add_bond_event
        # TODO: Implement add_bond_event
      end

      def add_faction_affiliation
        # TODO: Implement add_faction_affiliation
      end

      def adjust_faction_rep
        # TODO: Implement adjust_faction_rep
      end

      def add_npc_relationship
        # TODO: Implement add_npc_relationship
      end

      def adjust_npc_bond
        # TODO: Implement adjust_npc_bond
      end

      def get_bond_details
        # TODO: Implement get_bond_details
      end

      def party_statistics
        # TODO: Implement party_statistics
      end

      def set_character
        # TODO: Implement set_character
      end

      def set_campaign
        # TODO: Implement set_campaign
      end

      private

      def set_character_features::relationships::relationships
        @character_features::relationships::relationships = CharacterFeatures::relationships::relationships.find(params[:id])
      end

      def character_features::relationships::relationships_params
        params.require(:character_features::relationships::relationships).permit()
      end

    end
  end
end