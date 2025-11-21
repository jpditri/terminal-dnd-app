# frozen_string_literal: true

class CreateLootTableEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :loot_table_entries do |t|
      t.integer :loot_table_id, null: false
      t.string :treasure_type, null: false
      t.string :quantity_dice
      t.integer :weight, default: 1
      t.integer :item_id
      t.jsonb :treasure_data, default: {}
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :loot_table_entries, :discarded_at
  end
end