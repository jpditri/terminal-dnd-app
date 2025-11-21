# frozen_string_literal: true

class CreateWorlds < ActiveRecord::Migration[7.1]
  def change
    create_table :worlds do |t|
      t.string :name
      t.text :description
      t.jsonb :settings
      t.integer :creator_id
      t.string :visibility
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :worlds, :discarded_at
  end
end