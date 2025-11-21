# frozen_string_literal: true

class CreateCharacterClasses < ActiveRecord::Migration[7.1]
  def change
    create_table :character_classes do |t|
      t.string :name
      t.integer :hit_die
      t.string :primary_ability
      t.jsonb :saving_throw_proficiencies
      t.jsonb :skill_proficiencies
      t.jsonb :armor_proficiencies
      t.jsonb :weapon_proficiencies
      t.jsonb :starting_equipment
      t.jsonb :class_features
      t.string :spellcasting_ability
      t.text :description
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :character_classes, :discarded_at
  end
end