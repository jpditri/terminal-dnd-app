# frozen_string_literal: true

class CreateQuestLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :quest_logs do |t|
      t.integer :campaign_id
      t.integer :character_id
      t.string :title
      t.text :description
      t.string :status
      t.string :quest_type
      t.string :difficulty
      t.integer :experience_reward
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :deleted_at
      t.integer :priority, default: 0
      t.integer :gold_reward, default: 0
      t.jsonb :item_rewards, default: []
      t.jsonb :prerequisites, default: {}
      t.integer :quest_chain_id
      t.integer :parent_quest_id
      t.string :location
      t.jsonb :npc_ids, default: []
      t.boolean :assigned_to_party
      t.jsonb :milestone_data, default: {}
      t.integer :template_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :quest_logs, :discarded_at
  end
end