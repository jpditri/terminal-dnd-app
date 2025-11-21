# frozen_string_literal: true

class CreateRaces < ActiveRecord::Migration[7.1]
  def change
    create_table :races do |t|
      t.string :name
      t.string :size
      t.integer :speed
      t.jsonb :ability_increases
      t.jsonb :traits
      t.jsonb :languages
      t.text :description
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :races, :discarded_at
  end
end