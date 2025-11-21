# frozen_string_literal: true

class CreateCampaigns < ActiveRecord::Migration[7.1]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.text :description
      t.string :status
      t.string :visibility, default: "private"
      t.integer :dm_id
      t.string :theme
      t.string :world_time
      t.string :current_location
      t.jsonb :settings
      t.jsonb :house_rules
      t.integer :max_players
      t.string :timezone
      t.string :session_frequency
      t.boolean :ai_assistant_enabled
      t.datetime :deleted_at
      t.integer :world_id
      t.integer :min_level, default: 1
      t.integer :max_level, default: 20
      t.string :category
      t.jsonb :tags, default: []
      t.datetime :discarded_at
      t.integer :template_id
      t.boolean :looking_for_players
      t.integer :player_capacity
      t.string :play_style
      t.datetime :next_session_at
      t.timestamps
    end
    add_index :campaigns, :discarded_at
  end
end