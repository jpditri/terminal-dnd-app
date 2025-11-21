# frozen_string_literal: true

class CreateSoloSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :solo_sessions do |t|
      t.datetime :started_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :solo_sessions, :discarded_at
  end
end