# frozen_string_literal: true

class CreateContentLibraries < ActiveRecord::Migration[7.1]
  def change
    create_table :content_libraries do |t|
      t.integer :campaign_id
      t.string :content_type
      t.string :title
      t.text :description
      t.jsonb :content_data
      t.jsonb :tags
      t.boolean :ai_generated
      t.string :ai_model
      t.text :generation_prompt
      t.boolean :is_public
      t.integer :upvotes
      t.integer :downvotes
      t.integer :usage_count
      t.decimal :quality_rating
      t.boolean :reviewed
      t.datetime :deleted_at
      t.integer :user_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :content_libraries, :discarded_at
  end
end