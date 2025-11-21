# frozen_string_literal: true

class CreateSoloGameStates < ActiveRecord::Migration[7.1]
  def change
    create_table :solo_game_states do |t|
      t.string :current_scene
      t.string :current_location
      t.string :time_of_day
      t.string :weather
      t.boolean :combat_active
      t.jsonb :scene_data
      t.jsonb :npcs_present
      t.jsonb :active_quests
      t.jsonb :inventory_state
      t.jsonb :resources
      t.integer :solo_session_id
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :solo_game_states, :discarded_at
  end
end