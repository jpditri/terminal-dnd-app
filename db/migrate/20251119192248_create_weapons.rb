# frozen_string_literal: true

class CreateWeapons < ActiveRecord::Migration[7.1]
  def change
    create_table :weapons do |t|
      t.string :name, null: false
      t.string :damage_dice, null: false
      t.string :damage_type
      t.jsonb :properties, default: []
      t.string :versatile_damage
      t.integer :character_id
      t.integer :item_id
      t.boolean :active, default: true
      t.boolean :equipped
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :weapons, :discarded_at
  end
end