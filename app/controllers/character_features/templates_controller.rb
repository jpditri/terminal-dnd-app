# frozen_string_literal: true

module CharacterFeatures
  class TemplatesController < ApplicationController
    before_action :set_template, only: [:show, :edit, :update, :destroy, :rate, :publish, :fork]
    before_action :authorize_template, only: [:edit, :update, :destroy, :publish]

    def index
      @character_features::templateses = policy_scope(CharacterFeatures::templates)
      @character_features::templateses = @character_features::templateses.search(params[:q]) if params[:q].present?
      @character_features::templateses = @character_features::templateses.page(params[:page]).per(20)
    end

    def show
      authorize @character_features::templates
    end

    def new
      @character_features::templates = CharacterFeatures::templates.new
      authorize @character_features::templates
    end

    def create
      @character_features::templates = CharacterFeatures::templates.new(character_features::templates_params)
      authorize @character_features::templates

      respond_to do |format|
        if @character_features::templates.save
          format.html { redirect_to @character_features::templates, notice: 'CharacterFeatures::templates was successfully created.' }
          format.turbo_stream
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      authorize @character_features::templates
    end

    def update
      authorize @character_features::templates

      respond_to do |format|
        if @character_features::templates.update(character_features::templates_params)
          format.html { redirect_to @character_features::templates, notice: 'CharacterFeatures::templates was successfully updated.' }
          format.turbo_stream
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @character_features::templates

      @character_features::templates.destroy

      respond_to do |format|
        format.html { redirect_to character_features::templateses_path, notice: 'CharacterFeatures::templates was successfully deleted.' }
        format.turbo_stream
      end
    end

    def rate
      # TODO: Implement rate
    end

    def publish
      # TODO: Implement publish
    end

    def fork
      # TODO: Implement fork
    end

    def use
      # TODO: Implement use
    end

    def export
      # TODO: Implement export
    end

    def library
      # TODO: Implement library
    end

    def compare
      # TODO: Implement compare
    end

    def wizard
      # TODO: Implement wizard
    end

    def analytics
      # TODO: Implement analytics
    end

    def set_template
      # TODO: Implement set_template
    end

    def authorize_template
      # TODO: Implement authorize_template
    end

    private

    def set_character_features::templates
      @character_features::templates = CharacterFeatures::templates.find(params[:id])
    end

    def character_features::templates_params
      params.require(:character_features::templates).permit()
    end

  end
end