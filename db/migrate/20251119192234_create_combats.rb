# frozen_string_literal: true

class CreateCombats < ActiveRecord::Migration[7.1]
  def change
    create_table :combats do |t|
      t.integer :game_session_id
      t.string :status
      t.integer :current_round
      t.integer :current_turn
      t.datetime :started_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :combats, :discarded_at
  end
end