# frozen_string_literal: true

class CreateCampaignJoinRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_join_requests do |t|
      t.integer :campaign_id, null: false
      t.integer :user_id, null: false
      t.string :status
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :campaign_join_requests, :discarded_at
  end
end