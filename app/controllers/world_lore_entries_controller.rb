# frozen_string_literal: true

class WorldLoreEntriesController < ApplicationController
  before_action :set_world_lore_entry

  def index
    @world_lore_entrieses = policy_scope(WorldLoreEntries)
    @world_lore_entrieses = @world_lore_entrieses.search(params[:q]) if params[:q].present?
    @world_lore_entrieses = @world_lore_entrieses.page(params[:page]).per(20)
  end

  def show
    authorize @world_lore_entries
  end

  def edit
    authorize @world_lore_entries
  end

  def new
    @world_lore_entries = WorldLoreEntries.new
    authorize @world_lore_entries
  end

  def create
    @world_lore_entries = WorldLoreEntries.new(world_lore_entries_params)
    authorize @world_lore_entries

    respond_to do |format|
      if @world_lore_entries.save
        format.html { redirect_to @world_lore_entries, notice: 'WorldLoreEntries was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @world_lore_entries

    respond_to do |format|
      if @world_lore_entries.update(world_lore_entries_params)
        format.html { redirect_to @world_lore_entries, notice: 'WorldLoreEntries was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @world_lore_entries

    @world_lore_entries.destroy

    respond_to do |format|
      format.html { redirect_to world_lore_entrieses_path, notice: 'WorldLoreEntries was successfully deleted.' }
      format.turbo_stream
    end
  end

  def inline_update
    # TODO: Implement inline_update
  end

  def restore
    # TODO: Implement restore
  end

  def history
    # TODO: Implement history
  end

  def bulk_destroy
    # TODO: Implement bulk_destroy
  end

  def bulk_restore
    # TODO: Implement bulk_restore
  end

  def export
    # TODO: Implement export
  end

  def set_world_lore_entry
    # TODO: Implement set_world_lore_entry
  end

  private

  def set_world_lore_entries
    @world_lore_entries = WorldLoreEntries.find(params[:id])
  end

  def world_lore_entries_params
    params.require(:world_lore_entries).permit()
  end

end