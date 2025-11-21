# frozen_string_literal: true

class CreateDamageLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :damage_logs do |t|
      t.integer :combat_encounter_id, null: false
      t.string :source_type
      t.integer :source_id
      t.string :target_type
      t.integer :target_id
      t.integer :amount, null: false
      t.string :damage_type
      t.text :description
      t.integer :round_number
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :damage_logs, :discarded_at
  end
end