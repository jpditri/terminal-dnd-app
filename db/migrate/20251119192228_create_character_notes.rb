# frozen_string_literal: true

class CreateCharacterNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :character_notes do |t|
      t.string :title
      t.text :content
      t.string :note_type
      t.integer :character_id
      t.datetime :discarded_at
      t.string :note_category, default: "quick_note"
      t.jsonb :tags, default: []
      t.integer :session_number
      t.date :session_date
      t.string :priority, default: "medium"
      t.boolean :completed
      t.datetime :completed_at
      t.string :npc_name
      t.string :relationship_status
      t.string :faction_affiliation
      t.date :last_interaction_date
      t.jsonb :metadata, default: {}
      t.boolean :pinned
      t.integer :character_limit, default: 5000
      t.timestamps
    end
    add_index :character_notes, :discarded_at
  end
end