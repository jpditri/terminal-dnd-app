# frozen_string_literal: true

class CreateContentClones < ActiveRecord::Migration[7.1]
  def change
    create_table :content_clones do |t|
      t.integer :shared_content_id, null: false
      t.integer :user_id, null: false
      t.string :cloned_content_type, null: false
      t.integer :cloned_content_id, null: false
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :content_clones, :discarded_at
  end
end