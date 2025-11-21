# frozen_string_literal: true

class CreateAiDmOverrides < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_dm_overrides do |t|
      t.integer :ai_dm_assistant_id, null: false
      t.integer :ai_dm_suggestion_id, null: false
      t.integer :user_id, null: false
      t.text :original_suggestion, null: false
      t.text :dm_override, null: false
      t.string :override_type, null: false
      t.jsonb :context_when_overridden, null: false, default: {}
      t.jsonb :reasoning, null: false, default: {}
      t.timestamps
    end
  end
end