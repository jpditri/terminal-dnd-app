# frozen_string_literal: true

class CreateEncounters < ActiveRecord::Migration[7.1]
  def change
    create_table :encounters do |t|
      t.integer :campaign_id
      t.integer :game_session_id
      t.string :name
      t.text :description
      t.string :difficulty
      t.string :status
      t.integer :experience_awarded
      t.text :treasure_awarded
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :encounters, :discarded_at
  end
end