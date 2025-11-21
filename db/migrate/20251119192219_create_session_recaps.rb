# frozen_string_literal: true

class CreateSessionRecaps < ActiveRecord::Migration[7.1]
  def change
    create_table :session_recaps do |t|
      t.integer :game_session_id
      t.integer :generated_by_user_id
      t.text :summary
      t.jsonb :key_events
      t.jsonb :npcs_met
      t.jsonb :locations_visited
      t.text :combat_summary
      t.integer :experience_gained
      t.text :treasure_found
      t.jsonb :quests_updated
      t.boolean :auto_generated
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :session_recaps, :discarded_at
  end
end