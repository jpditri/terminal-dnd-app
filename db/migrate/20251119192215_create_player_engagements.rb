# frozen_string_literal: true

class CreatePlayerEngagements < ActiveRecord::Migration[7.1]
  def change
    create_table :player_engagements do |t|
      t.integer :campaign_id
      t.integer :character_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :player_engagements, :discarded_at
  end
end