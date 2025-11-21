# frozen_string_literal: true

class CreateFactionRelationships < ActiveRecord::Migration[7.1]
  def change
    create_table :faction_relationships do |t|
      t.integer :related_faction_id
      t.string :relationship_type
      t.integer :relationship_strength
      t.text :history
      t.jsonb :treaties
      t.jsonb :conflicts
      t.datetime :deleted_at
      t.integer :faction_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :faction_relationships, :discarded_at
  end
end