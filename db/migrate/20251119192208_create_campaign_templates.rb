# frozen_string_literal: true

class CreateCampaignTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_templates do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.text :description
      t.string :category
      t.jsonb :tags, default: []
      t.jsonb :template_data, null: false, default: {}
      t.string :visibility, null: false, default: "public"
      t.integer :min_level, default: 1
      t.integer :max_level, default: 20
      t.integer :use_count, null: false, default: 0
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :campaign_templates, :discarded_at
  end
end