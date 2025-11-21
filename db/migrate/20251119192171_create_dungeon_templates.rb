# frozen_string_literal: true

class CreateDungeonTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :dungeon_templates do |t|
      t.string :name
      t.text :description
      t.string :dungeon_type
      t.integer :min_party_level
      t.integer :max_party_level
      t.integer :room_count_min
      t.integer :room_count_max
      t.string :monster_density
      t.string :trap_density
      t.string :treasure_quality
      t.jsonb :themes
      t.jsonb :special_features
      t.integer :created_by_user_id
      t.boolean :is_public
      t.integer :usage_count
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :dungeon_templates, :discarded_at
  end
end