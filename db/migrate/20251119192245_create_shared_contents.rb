# frozen_string_literal: true

class CreateSharedContents < ActiveRecord::Migration[7.1]
  def change
    create_table :shared_contents do |t|
      t.integer :user_id, null: false
      t.string :content_type, null: false
      t.integer :content_id, null: false
      t.string :title, null: false
      t.text :description
      t.string :visibility, null: false, default: "public"
      t.string :license_type, null: false, default: "cc_by"
      t.integer :view_count, null: false, default: 0
      t.integer :clone_count, null: false, default: 0
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :shared_contents, :discarded_at
  end
end