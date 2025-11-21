# frozen_string_literal: true

class CreateUserBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :user_blocks do |t|
      t.integer :blocker_id, null: false
      t.integer :blocked_id, null: false
      t.string :reason
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :user_blocks, :discarded_at
  end
end