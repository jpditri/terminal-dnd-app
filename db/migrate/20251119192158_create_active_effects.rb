# frozen_string_literal: true

class CreateActiveEffects < ActiveRecord::Migration[7.1]
  def change
    create_table :active_effects do |t|
      t.integer :combatant_id, null: false
      t.string :effect_type, null: false
      t.string :name
      t.text :description
      t.integer :value
      t.integer :duration_rounds
      t.integer :save_dc
      t.string :trigger
      t.jsonb :metadata, default: {}
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :active_effects, :discarded_at
  end
end