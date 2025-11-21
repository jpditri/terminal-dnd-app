# frozen_string_literal: true

class CreateCharacterTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :character_templates do |t|
      t.string :name, null: false
      t.string :template_type
      t.text :description
      t.jsonb :template_data, default: {}
      t.integer :user_id
      t.boolean :is_public
      t.integer :usage_count, default: 0
      t.integer :rating_sum, default: 0
      t.integer :rating_count, default: 0
      t.jsonb :tags, default: []
      t.jsonb :compatible_classes, default: []
      t.integer :min_level
      t.integer :max_level
      t.timestamps
    end
  end
end