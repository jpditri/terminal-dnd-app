# frozen_string_literal: true

class CreateHomebrewItems < ActiveRecord::Migration[7.1]
  def change
    create_table :homebrew_items do |t|
      t.integer :campaign_id
      t.string :homebrew_type
      t.string :name
      t.text :description
      t.jsonb :stat_block
      t.string :source_reference
      t.integer :balance_rating
      t.boolean :published
      t.integer :upvotes
      t.datetime :deleted_at
      t.integer :user_id
      t.jsonb :content
      t.string :visibility, default: "private"
      t.integer :version, default: 1
      t.string :tags
      t.text :balance_notes
      t.boolean :active, default: true
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :homebrew_items, :discarded_at
  end
end