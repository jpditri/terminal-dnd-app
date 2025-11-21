# frozen_string_literal: true

class CreateChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_messages do |t|
      t.integer :user_id, null: false
      t.integer :game_session_id, null: false
      t.text :content, null: false
      t.string :message_type, default: "public"
      t.integer :recipient_id
      t.integer :character_id
      t.boolean :private
      t.boolean :edited
      t.boolean :deleted
      t.string :deleted_by
      t.text :original_content
      t.jsonb :dice_results, default: []
      t.jsonb :mentions, default: []
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :chat_messages, :discarded_at
  end
end