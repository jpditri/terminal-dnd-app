# frozen_string_literal: true

class CreateAiDmSuggestions < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_dm_suggestions do |t|
      t.integer :ai_dm_assistant_id, null: false
      t.integer :game_session_id
      t.integer :user_id, null: false
      t.string :suggestion_type, null: false
      t.text :content, null: false
      t.text :edited_content
      t.string :status
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :ai_dm_suggestions, :discarded_at
  end
end