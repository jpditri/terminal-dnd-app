# frozen_string_literal: true

class CreateCampaignMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_memberships do |t|
      t.string :role
      t.boolean :active
      t.integer :user_id
      t.integer :campaign_id
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :campaign_memberships, :discarded_at
  end
end