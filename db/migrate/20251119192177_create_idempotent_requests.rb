# frozen_string_literal: true

class CreateIdempotentRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :idempotent_requests do |t|
      t.string :idempotency_key, null: false
      t.integer :character_id, null: false
      t.string :action_type, null: false
      t.jsonb :response_data
      t.integer :status_code
      t.timestamps
    end
  end
end