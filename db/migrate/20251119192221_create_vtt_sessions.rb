# frozen_string_literal: true

class CreateVttSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :vtt_sessions do |t|
      t.integer :game_session_id, null: false
      t.integer :campaign_id, null: false
      t.integer :location_id
      t.integer :encounter_id
      t.integer :grid_size, null: false, default: 50
      t.string :grid_type, null: false, default: "square"
      t.decimal :zoom_level, default: "1.0"
      t.boolean :active, null: false, default: true
      t.integer :round_number, default: 0
      t.jsonb :state_snapshot, default: {}
      t.timestamps
    end
  end
end