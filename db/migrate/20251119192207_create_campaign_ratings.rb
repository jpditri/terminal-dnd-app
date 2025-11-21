# frozen_string_literal: true

class CreateCampaignRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_ratings do |t|
      t.integer :campaign_id, null: false
      t.integer :user_id, null: false
      t.integer :rating, null: false
      t.text :review
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :campaign_ratings, :discarded_at
  end
end