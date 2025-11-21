# frozen_string_literal: true

module CharacterFeatures
  module Homebrew
    class HomebrewsController < ApplicationController
      before_action :set_homebrew_item, only: [:show, :edit, :update, :destroy, :publish, :version_history, :rollback]
      before_action :authorize_owner, only: [:edit, :update, :destroy]

      def index
        @character_features::homebrew::homebrewses = policy_scope(CharacterFeatures::homebrew::homebrews)
        @character_features::homebrew::homebrewses = @character_features::homebrew::homebrewses.search(params[:q]) if params[:q].present?
        @character_features::homebrew::homebrewses = @character_features::homebrew::homebrewses.page(params[:page]).per(20)
      end

      def new
        @character_features::homebrew::homebrews = CharacterFeatures::homebrew::homebrews.new
        authorize @character_features::homebrew::homebrews
      end

      def create
        @character_features::homebrew::homebrews = CharacterFeatures::homebrew::homebrews.new(character_features::homebrew::homebrews_params)
        authorize @character_features::homebrew::homebrews

        respond_to do |format|
          if @character_features::homebrew::homebrews.save
            format.html { redirect_to @character_features::homebrew::homebrews, notice: 'CharacterFeatures::homebrew::homebrews was successfully created.' }
            format.turbo_stream
          else
            format.html { render :new, status: :unprocessable_entity }
          end
        end
      end

      def show
        authorize @character_features::homebrew::homebrews
      end

      def edit
        authorize @character_features::homebrew::homebrews
      end

      def update
        authorize @character_features::homebrew::homebrews

        respond_to do |format|
          if @character_features::homebrew::homebrews.update(character_features::homebrew::homebrews_params)
            format.html { redirect_to @character_features::homebrew::homebrews, notice: 'CharacterFeatures::homebrew::homebrews was successfully updated.' }
            format.turbo_stream
          else
            format.html { render :edit, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        authorize @character_features::homebrew::homebrews

        @character_features::homebrew::homebrews.destroy

        respond_to do |format|
          format.html { redirect_to character_features::homebrew::homebrewses_path, notice: 'CharacterFeatures::homebrew::homebrews was successfully deleted.' }
          format.turbo_stream
        end
      end

      def publish
        # TODO: Implement publish
      end

      def validate_balance
        # TODO: Implement validate_balance
      end

      def preview
        # TODO: Implement preview
      end

      def duplicate
        # TODO: Implement duplicate
      end

      def export
        # TODO: Implement export
      end

      def import
        # TODO: Implement import
      end

      def version_history
        # TODO: Implement version_history
      end

      def rollback
        # TODO: Implement rollback
      end

      def templates
        # TODO: Implement templates
      end

      def set_homebrew_item
        # TODO: Implement set_homebrew_item
      end

      def authorize_owner
        # TODO: Implement authorize_owner
      end

      private

      def set_character_features::homebrew::homebrews
        @character_features::homebrew::homebrews = CharacterFeatures::homebrew::homebrews.find(params[:id])
      end

      def character_features::homebrew::homebrews_params
        params.require(:character_features::homebrew::homebrews).permit()
      end

    end
  end
end