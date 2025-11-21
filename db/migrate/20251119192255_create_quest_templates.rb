# frozen_string_literal: true

class CreateQuestTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :quest_templates do |t|
      t.string :name
      t.text :description
      t.string :quest_type
      t.string :difficulty
      t.jsonb :objectives
      t.jsonb :rewards
      t.jsonb :prerequisites
      t.string :icon
      t.string :color
      t.string :category
      t.integer :estimated_duration_minutes
      t.integer :min_party_level
      t.integer :max_party_level
      t.jsonb :location_tags
      t.jsonb :npc_tags
      t.timestamps
    end
  end
end