# frozen_string_literal: true

class CreateCharacterRelationships < ActiveRecord::Migration[7.1]
  def change
    create_table :character_relationships do |t|
      t.integer :character_id, null: false
      t.integer :related_character_id
      t.string :relationship_type
      t.integer :bond_strength, default: 50
      t.jsonb :shared_history, default: []
      t.jsonb :relationship_modifiers, default: {}
      t.text :notes
      t.boolean :is_npc
      t.string :npc_name
      t.timestamps
    end
  end
end