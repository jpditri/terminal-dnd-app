# frozen_string_literal: true

class CreateAiMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_messages do |t|
      t.string :role
      t.text :content
      t.jsonb :dice_rolls
      t.jsonb :narrative_tags
      t.integer :tokens_used
      t.integer :response_time_ms
      t.datetime :deleted_at
      t.integer :ai_conversation_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :ai_messages, :discarded_at
  end
end