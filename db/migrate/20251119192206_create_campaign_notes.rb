# frozen_string_literal: true

class CreateCampaignNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_notes do |t|
      t.string :title
      t.text :content
      t.string :note_type
      t.string :visibility
      t.integer :campaign_id
      t.integer :user_id
      t.integer :game_session_id
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :campaign_notes, :discarded_at
  end
end