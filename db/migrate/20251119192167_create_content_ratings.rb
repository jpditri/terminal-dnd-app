# frozen_string_literal: true

class CreateContentRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :content_ratings do |t|
      t.integer :shared_content_id, null: false
      t.integer :user_id, null: false
      t.integer :rating, null: false
      t.text :review
      t.integer :helpful_count, null: false, default: 0
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :content_ratings, :discarded_at
  end
end