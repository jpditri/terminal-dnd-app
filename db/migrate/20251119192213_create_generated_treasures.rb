# frozen_string_literal: true

class CreateGeneratedTreasures < ActiveRecord::Migration[7.1]
  def change
    create_table :generated_treasures do |t|
      t.integer :campaign_id
      t.integer :character_id
      t.integer :loot_table_id, null: false
      t.jsonb :treasure_data, default: {}
      t.datetime :generated_at
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :generated_treasures, :discarded_at
  end
end