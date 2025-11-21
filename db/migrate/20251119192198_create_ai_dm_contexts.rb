# frozen_string_literal: true

class CreateAiDmContexts < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_dm_contexts do |t|
      t.integer :ai_dm_assistant_id, null: false
      t.integer :game_session_id, null: false
      t.jsonb :conversation_history, null: false, default: []
      t.jsonb :active_npcs, null: false, default: []
      t.jsonb :recent_events, null: false, default: []
      t.jsonb :unresolved_threads, null: false, default: []
      t.jsonb :campaign_memory, null: false, default: {}
      t.timestamps
    end
  end
end