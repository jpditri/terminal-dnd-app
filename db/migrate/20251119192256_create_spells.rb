# frozen_string_literal: true

class CreateSpells < ActiveRecord::Migration[7.1]
  def change
    create_table :spells do |t|
      t.string :name
      t.integer :level
      t.string :school
      t.string :casting_time
      t.string :range
      t.jsonb :components
      t.string :duration
      t.boolean :concentration
      t.boolean :ritual
      t.text :description
      t.text :higher_levels
      t.jsonb :classes
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :spells, :discarded_at
  end
end