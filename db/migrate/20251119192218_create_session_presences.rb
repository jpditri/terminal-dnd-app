# frozen_string_literal: true

class CreateSessionPresences < ActiveRecord::Migration[7.1]
  def change
    create_table :session_presences do |t|
      t.integer :user_id, null: false
      t.integer :game_session_id, null: false
      t.string :status, null: false, default: "offline"
      t.integer :connection_count, null: false, default: 0
      t.datetime :last_activity_at
      t.datetime :disconnected_at
      t.string :status_message
      t.boolean :manual_status, null: false
      t.string :ip_address
      t.timestamps
    end
  end
end