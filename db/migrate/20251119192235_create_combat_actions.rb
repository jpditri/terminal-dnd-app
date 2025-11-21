# frozen_string_literal: true

class CreateCombatActions < ActiveRecord::Migration[7.1]
  def change
    create_table :combat_actions do |t|
      t.integer :round_number
      t.string :action_type
      t.integer :target_participant_id
      t.text :description
      t.integer :attack_roll
      t.integer :damage_roll
      t.string :damage_type
      t.integer :healing_amount
      t.integer :spell_id
      t.integer :item_id
      t.boolean :success
      t.boolean :critical_hit
      t.boolean :critical_fail
      t.datetime :deleted_at
      t.integer :combat_id
      t.integer :combat_participant_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :combat_actions, :discarded_at
  end
end