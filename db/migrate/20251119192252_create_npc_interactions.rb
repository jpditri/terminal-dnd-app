# frozen_string_literal: true

class CreateNpcInteractions < ActiveRecord::Migration[7.1]
  def change
    create_table :npc_interactions do |t|
      t.integer :character_id
      t.integer :game_session_id
      t.string :interaction_type
      t.text :summary
      t.text :player_action
      t.text :npc_response
      t.integer :relationship_change
      t.integer :quest_log_id
      t.jsonb :metadata
      t.datetime :occurred_at
      t.datetime :deleted_at
      t.integer :npc_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :npc_interactions, :discarded_at
  end
end