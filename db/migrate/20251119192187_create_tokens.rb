# frozen_string_literal: true

class CreateTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :tokens do |t|
      t.integer :character_id
      t.string :name
      t.string :token_type
      t.integer :grid_x
      t.integer :grid_y
      t.string :size
      t.string :color
      t.string :icon
      t.boolean :visible_to_players
      t.integer :current_hit_points
      t.integer :max_hit_points
      t.datetime :deleted_at
      t.integer :map_id
      t.integer :encounter_monster_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :tokens, :discarded_at
  end
end