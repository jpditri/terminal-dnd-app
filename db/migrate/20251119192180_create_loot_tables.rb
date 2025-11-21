# frozen_string_literal: true

class CreateLootTables < ActiveRecord::Migration[7.1]
  def change
    create_table :loot_tables do |t|
      t.string :name, null: false
      t.text :description
      t.string :table_type
      t.decimal :challenge_rating_min
      t.decimal :challenge_rating_max
      t.string :source
      t.integer :user_id
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :loot_tables, :discarded_at
  end
end