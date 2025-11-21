# frozen_string_literal: true

class CreateSpellFilterPresets < ActiveRecord::Migration[7.1]
  def change
    create_table :spell_filter_presets do |t|
      t.integer :user_id
      t.string :name, null: false
      t.text :description
      t.jsonb :filter_data, null: false, default: {}
      t.boolean :is_default, null: false
      t.boolean :is_public, null: false
      t.string :preset_type, null: false, default: "custom"
      t.integer :usage_count, null: false, default: 0
      t.timestamps
    end
  end
end