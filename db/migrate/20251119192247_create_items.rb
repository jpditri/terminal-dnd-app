# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name
      t.string :item_type
      t.string :rarity
      t.text :description
      t.jsonb :properties
      t.decimal :weight
      t.decimal :cost_gp
      t.boolean :magic
      t.boolean :requires_attunement
      t.datetime :discarded_at
      t.string :source
      t.integer :armor_class
      t.string :armor_type
      t.timestamps
    end
    add_index :items, :discarded_at
  end
end