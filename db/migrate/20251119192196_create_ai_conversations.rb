# frozen_string_literal: true

class CreateAiConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_conversations do |t|
      t.integer :solo_session_id
      t.integer :character_id
      t.string :title
      t.string :status
      t.string :ai_model
      t.text :system_prompt
      t.jsonb :context_data
      t.integer :message_count
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :ai_conversations, :discarded_at
  end
end