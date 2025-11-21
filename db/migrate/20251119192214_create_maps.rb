# frozen_string_literal: true

class CreateMaps < ActiveRecord::Migration[7.1]
  def change
    create_table :maps do |t|
      t.integer :campaign_id
      t.string :name
      t.text :description
      t.integer :grid_width
      t.integer :grid_height
      t.integer :grid_size
      t.string :background_color
      t.jsonb :terrain_data
      t.boolean :fog_of_war_enabled
      t.jsonb :fog_of_war_data
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :maps, :discarded_at
  end
end