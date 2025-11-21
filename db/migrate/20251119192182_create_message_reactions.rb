# frozen_string_literal: true

class CreateMessageReactions < ActiveRecord::Migration[7.1]
  def change
    create_table :message_reactions do |t|
      t.integer :chat_message_id, null: false
      t.integer :user_id, null: false
      t.string :emoji, null: false
      t.timestamps
    end
  end
end