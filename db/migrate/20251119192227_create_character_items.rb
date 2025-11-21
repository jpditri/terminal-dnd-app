# frozen_string_literal: true

class CreateCharacterItems < ActiveRecord::Migration[7.1]
  def change
    create_table :character_items do |t|
      t.integer :quantity
      t.boolean :equipped
      t.boolean :attuned
      t.boolean :identified
      t.text :notes
      t.integer :character_id
      t.integer :item_id
      t.datetime :discarded_at
      t.integer :lock_version, null: false, default: 0
      t.string :equipment_slot
      t.timestamps
    end
    add_index :character_items, :discarded_at
  end
end