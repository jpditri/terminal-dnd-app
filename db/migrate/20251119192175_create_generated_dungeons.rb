# frozen_string_literal: true

class CreateGeneratedDungeons < ActiveRecord::Migration[7.1]
  def change
    create_table :generated_dungeons do |t|
      t.integer :campaign_id
      t.string :name
      t.integer :party_level
      t.integer :room_count
      t.jsonb :layout_data
      t.jsonb :room_descriptions
      t.jsonb :monster_placements
      t.jsonb :trap_locations
      t.jsonb :treasure_locations
      t.jsonb :secret_areas
      t.string :boss_room_id
      t.string :entrance_room_id
      t.text :narrative_theme
      t.string :difficulty_rating
      t.datetime :generated_at
      t.jsonb :explored_rooms
      t.datetime :deleted_at
      t.integer :dungeon_template_id
      t.integer :location_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :generated_dungeons, :discarded_at
  end
end