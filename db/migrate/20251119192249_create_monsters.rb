# frozen_string_literal: true

class CreateMonsters < ActiveRecord::Migration[7.1]
  def change
    create_table :monsters do |t|
      t.string :name
      t.string :size
      t.string :creature_type
      t.integer :alignment_id
      t.integer :armor_class
      t.integer :hit_points
      t.string :hit_dice
      t.string :speed
      t.integer :strength
      t.integer :dexterity
      t.integer :constitution
      t.integer :intelligence
      t.integer :wisdom
      t.integer :charisma
      t.decimal :challenge_rating
      t.integer :experience_points
      t.jsonb :skills
      t.text :damage_vulnerabilities
      t.text :damage_resistances
      t.text :damage_immunities
      t.text :condition_immunities
      t.text :senses
      t.text :languages
      t.text :description
      t.string :source
      t.datetime :deleted_at
      t.jsonb :saving_throws
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :monsters, :discarded_at
  end
end