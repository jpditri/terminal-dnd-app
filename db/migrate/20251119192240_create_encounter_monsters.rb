# frozen_string_literal: true

class CreateEncounterMonsters < ActiveRecord::Migration[7.1]
  def change
    create_table :encounter_monsters do |t|
      t.integer :quantity
      t.integer :current_hit_points
      t.integer :max_hit_points
      t.integer :initiative
      t.jsonb :conditions
      t.text :notes
      t.boolean :defeated
      t.datetime :deleted_at
      t.integer :encounter_id
      t.integer :monster_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :encounter_monsters, :discarded_at
  end
end