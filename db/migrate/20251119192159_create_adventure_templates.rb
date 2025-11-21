# frozen_string_literal: true

class CreateAdventureTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :adventure_templates do |t|
      t.string :title, null: false
      t.text :description
      t.string :difficulty, default: "medium"
      t.integer :estimated_duration
      t.integer :min_level, default: 1
      t.integer :max_level, default: 20
      t.string :category
      t.string :status, default: "draft"
      t.jsonb :template_data, default: {}
      t.integer :creator_id
      t.integer :completion_count, default: 0
      t.integer :usage_count, default: 0
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :adventure_templates, :discarded_at
  end
end