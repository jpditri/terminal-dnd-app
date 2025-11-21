# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, default: "user"
      t.datetime :discarded_at
      t.string :username
      t.text :bio
      t.string :avatar_url
      t.integer :experience_points
      t.integer :level
      t.string :preferences
      t.string :timezone
      t.datetime :last_active_at
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :users, :discarded_at
  end
end