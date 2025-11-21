# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.integer :world_id
      t.integer :parent_location_id
      t.string :name
      t.string :location_type
      t.text :description
      t.integer :population
      t.string :government_type
      t.jsonb :notable_features
      t.jsonb :shops
      t.jsonb :taverns
      t.jsonb :points_of_interest
      t.string :climate
      t.string :terrain
      t.integer :coordinates_x
      t.integer :coordinates_y
      t.integer :danger_level
      t.boolean :visited
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :locations, :discarded_at
  end
end