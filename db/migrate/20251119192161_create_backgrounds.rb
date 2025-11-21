# frozen_string_literal: true

class CreateBackgrounds < ActiveRecord::Migration[7.1]
  def change
    create_table :backgrounds do |t|
      t.string :name
      t.jsonb :skill_proficiencies
      t.jsonb :tool_proficiencies
      t.jsonb :languages
      t.jsonb :starting_equipment
      t.string :feature_name
      t.text :feature_description
      t.text :description
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :backgrounds, :discarded_at
  end
end