# frozen_string_literal: true

class CreateFriendships < ActiveRecord::Migration[7.1]
  def change
    create_table :friendships do |t|
      t.integer :user_id, null: false
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :friendships, :discarded_at
  end
end