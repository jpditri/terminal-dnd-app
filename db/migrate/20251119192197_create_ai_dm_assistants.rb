# frozen_string_literal: true

class CreateAiDmAssistants < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_dm_assistants do |t|
      t.integer :campaign_id, null: false
      t.boolean :enabled, null: false, default: true
      t.boolean :paused, null: false
      t.string :creativity_level, null: false, default: "balanced"
      t.string :tone, null: false, default: "heroic"
      t.text :setting_context
      t.jsonb :suggestion_types, null: false
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :ai_dm_assistants, :discarded_at
  end
end