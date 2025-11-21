# frozen_string_literal: true

class CreateFactions < ActiveRecord::Migration[7.1]
  def change
    create_table :factions do |t|
      t.integer :campaign_id
      t.integer :world_id
      t.string :name
      t.string :faction_type
      t.integer :alignment_id
      t.text :description
      t.jsonb :goals
      t.jsonb :resources
      t.jsonb :territory
      t.integer :power_level
      t.integer :headquarters_location_id
      t.integer :leader_npc_id
      t.text :symbols
      t.string :colors
      t.string :motto
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :factions, :discarded_at
  end
end