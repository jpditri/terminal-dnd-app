# frozen_string_literal: true

class CreateVttMaps < ActiveRecord::Migration[7.1]
  def change
    create_table :vtt_maps do |t|
      t.integer :vtt_session_id, null: false
      t.string :background_url, null: false
      t.integer :width, null: false, default: 30
      t.integer :height, null: false, default: 20
      t.boolean :grid_overlay, null: false, default: true
      t.jsonb :terrain_features, default: []
      t.jsonb :metadata, default: {}
      t.timestamps
    end
  end
end