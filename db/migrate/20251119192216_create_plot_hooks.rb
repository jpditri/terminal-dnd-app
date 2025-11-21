# frozen_string_literal: true

class CreatePlotHooks < ActiveRecord::Migration[7.1]
  def change
    create_table :plot_hooks do |t|
      t.integer :campaign_id
      t.integer :created_by_user_id
      t.string :title
      t.text :description
      t.string :hook_type
      t.string :urgency
      t.string :complexity
      t.integer :suggested_level_min
      t.integer :suggested_level_max
      t.jsonb :factions_involved
      t.jsonb :npcs_involved
      t.jsonb :locations_involved
      t.jsonb :rewards_suggested
      t.jsonb :complications
      t.string :status
      t.integer :converted_to_quest_id
      t.boolean :ai_generated
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :plot_hooks, :discarded_at
  end
end