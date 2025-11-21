# frozen_string_literal: true

class CreateEncounterTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :encounter_templates do |t|
      t.string :name
      t.text :description
      t.integer :min_party_level
      t.integer :max_party_level
      t.jsonb :monster_types
      t.jsonb :terrain_types
      t.decimal :difficulty_modifier
      t.jsonb :environmental_hazards
      t.jsonb :objectives
      t.jsonb :rewards
      t.integer :created_by_user_id
      t.boolean :is_public
      t.integer :usage_count
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :encounter_templates, :discarded_at
  end
end