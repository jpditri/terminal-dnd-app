# frozen_string_literal: true

class CreateCharacterInventories < ActiveRecord::Migration[7.1]
  def change
    create_table :character_inventories do |t|
      t.integer :character_id, null: false
      t.jsonb :equipped_items, default: {}
      t.jsonb :inventory_grid, default: []
      t.integer :carry_capacity, default: 150
      t.integer :current_weight, default: 0
      t.jsonb :equipment_sets, default: {}
      t.string :active_set
      t.jsonb :currency
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :character_inventories, :discarded_at
  end
end