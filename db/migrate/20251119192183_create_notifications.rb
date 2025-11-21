# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.integer :user_id, null: false
      t.string :notifiable_type
      t.integer :notifiable_id
      t.string :notification_type, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.string :priority, null: false, default: "medium"
      t.jsonb :metadata, default: {}
      t.datetime :read_at
      t.string :action_url
      t.timestamps
    end
  end
end