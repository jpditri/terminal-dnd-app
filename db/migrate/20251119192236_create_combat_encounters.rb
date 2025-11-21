# frozen_string_literal: true

class CreateCombatEncounters < ActiveRecord::Migration[7.1]
  def change
    create_table :combat_encounters do |t|
      t.integer :campaign_id, null: false
      t.integer :game_session_id
      t.string :status, null: false, default: "preparing"
      t.integer :current_round, default: 0
      t.integer :current_turn, default: 0
      t.integer :current_turn_combatant_id
      t.boolean :paused
      t.integer :turn_timer_seconds
      t.datetime :turn_started_at
      t.datetime :started_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :combat_encounters, :discarded_at
  end
end