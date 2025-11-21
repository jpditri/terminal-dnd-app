# frozen_string_literal: true

class CreateConditions < ActiveRecord::Migration[7.1]
  def change
    create_table :conditions do |t|
      t.string :name
      t.text :description
      t.jsonb :effects
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :conditions, :discarded_at
  end
end