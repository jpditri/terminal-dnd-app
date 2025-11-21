# frozen_string_literal: true

class CreateWorldLoreEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :world_lore_entries do |t|
      t.string :title
      t.string :entry_type
      t.text :content
      t.jsonb :tags
      t.jsonb :metadata
      t.string :visibility
      t.integer :created_by_id
      t.datetime :deleted_at
      t.integer :world_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :world_lore_entries, :discarded_at
  end
end