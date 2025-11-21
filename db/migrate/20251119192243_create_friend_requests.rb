# frozen_string_literal: true

class CreateFriendRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :friend_requests do |t|
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :friend_requests, :discarded_at
  end
end