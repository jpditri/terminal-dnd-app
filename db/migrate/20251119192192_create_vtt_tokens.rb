# frozen_string_literal: true

class CreateVttTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :vtt_tokens do |t|
      t.integer :vtt_session_id, null: false
      t.integer :character_id
      t.integer :npc_id
      t.integer :monster_id
      t.decimal :x, null: false, default: "0.0"
      t.decimal :y, null: false, default: "0.0"
      t.integer :rotation, null: false, default: 0
      t.boolean :hidden, null: false
      t.string :size, null: false, default: "medium"
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
  end
end