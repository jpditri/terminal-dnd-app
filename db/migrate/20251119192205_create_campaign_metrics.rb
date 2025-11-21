# frozen_string_literal: true

class CreateCampaignMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_metrics do |t|
      t.integer :campaign_id
      t.date :metric_date
      t.integer :sessions_count
      t.integer :total_playtime_minutes
      t.integer :encounters_count
      t.integer :combats_count
      t.integer :npcs_met_count
      t.integer :quests_started
      t.integer :quests_completed
      t.integer :locations_visited
      t.integer :player_deaths
      t.integer :monsters_defeated
      t.decimal :treasure_gained_gp
      t.integer :experience_gained
      t.jsonb :engagement_scores
      t.jsonb :pacing_analysis
      t.datetime :deleted_at
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :campaign_metrics, :discarded_at
  end
end