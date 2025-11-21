# frozen_string_literal: true

class CreateGameSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :game_sessions do |t|
      t.string :title
      t.integer :session_number
      t.datetime :scheduled_at
      t.datetime :started_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :game_sessions, :discarded_at
  end
end