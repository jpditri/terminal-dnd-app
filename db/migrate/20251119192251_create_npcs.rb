# frozen_string_literal: true

class CreateNpcs < ActiveRecord::Migration[7.1]
  def change
    create_table :npcs do |t|
      t.integer :campaign_id
      t.integer :world_id
      t.string :name
      t.integer :race_id
      t.integer :character_class_id
      t.string :occupation
      t.integer :age
      t.integer :alignment_id
      t.text :personality_traits
      t.text :ideals
      t.text :bonds
      t.text :flaws
      t.string :voice_style
      t.text :speech_patterns
      t.jsonb :motivations
      t.jsonb :secrets
      t.jsonb :relationships
      t.string :status
      t.text :backstory
      t.jsonb :ai_personality_profile
      t.jsonb :conversation_memory
      t.string :importance_level
      t.datetime :deleted_at
      t.integer :faction_id
      t.integer :location_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :npcs, :discarded_at
  end
end