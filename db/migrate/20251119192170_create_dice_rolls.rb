# frozen_string_literal: true

class CreateDiceRolls < ActiveRecord::Migration[7.1]
  def change
    create_table :dice_rolls do |t|
      t.integer :character_id
      t.integer :game_session_id
      t.string :roll_type
      t.string :dice_formula
      t.jsonb :results
      t.integer :total
      t.integer :modifier
      t.boolean :advantage
      t.boolean :disadvantage
      t.boolean :critical
      t.string :context
      t.datetime :deleted_at
      t.integer :user_id
      t.integer :combat_id
      t.integer :combat_action_id
      t.boolean :hidden, null: false
      t.boolean :active, null: false, default: true
      t.string :ability
      t.text :metadata
      t.string :state, null: false, default: "rolled"
      t.boolean :locked, null: false
      t.integer :original_roll_id
      t.integer :superseded_by_roll_id
      t.text :reroll_reason
      t.integer :dm_approved_by
      t.datetime :dm_approved_at
      t.datetime :reroll_requested_at
      t.boolean :auto_confirmed, null: false
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :dice_rolls, :discarded_at
  end
end