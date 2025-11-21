# frozen_string_literal: true

class CreateActionLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :action_logs do |t|
      t.integer :user_id, null: false
      t.integer :game_session_id, null: false
      t.string :action_type, null: false
      t.text :description
      t.jsonb :metadata, default: {}
      t.timestamps
    end
  end
end