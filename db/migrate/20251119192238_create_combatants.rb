# frozen_string_literal: true

class CreateCombatants < ActiveRecord::Migration[7.1]
  def change
    create_table :combatants do |t|
      t.integer :combat_encounter_id, null: false
      t.integer :character_id
      t.string :name
      t.string :combatant_type, null: false, default: "pc"
      t.integer :initiative
      t.integer :dexterity
      t.string :status, default: "conscious"
      t.integer :death_save_successes, default: 0
      t.integer :death_save_failures, default: 0
      t.integer :challenge_rating
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :combatants, :discarded_at
  end
end