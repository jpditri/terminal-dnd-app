# frozen_string_literal: true

class CreateCharacterAiAssistants < ActiveRecord::Migration[7.1]
  def change
    create_table :character_ai_assistants do |t|
      t.integer :character_id, null: false
      t.jsonb :conversation_history, default: []
      t.jsonb :generated_content, default: {}
      t.jsonb :tactical_suggestions, default: []
      t.jsonb :roleplay_prompts, default: []
      t.jsonb :personality_analysis, default: {}
      t.string :preferred_ai_model
      t.integer :ai_usage_tokens, default: 0
      t.boolean :ai_enabled, default: true
      t.jsonb :custom_instructions, default: {}
      t.timestamps
    end
  end
end