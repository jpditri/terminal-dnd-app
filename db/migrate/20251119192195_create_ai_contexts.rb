# frozen_string_literal: true

class CreateAiContexts < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_contexts do |t|
      t.integer :character_id, null: false
      t.integer :solo_session_id
      t.jsonb :long_term_memory, null: false, default: {}
      t.jsonb :character_traits, null: false, default: {}
      t.jsonb :world_state, null: false, default: {}
      t.jsonb :relationship_web, null: false, default: {}
      t.jsonb :active_quests, null: false, default: []
      t.jsonb :plot_threads, null: false, default: []
      t.jsonb :npcs_met, null: false, default: []
      t.jsonb :locations_visited, null: false, default: []
      t.jsonb :important_items, null: false, default: []
      t.jsonb :major_events, null: false, default: []
      t.jsonb :session_summaries, null: false, default: []
      t.text :context_seed
      t.datetime :last_context_update
      t.integer :context_version, null: false, default: 1
      t.integer :estimated_token_count, null: false, default: 0
      t.timestamps
    end
  end
end