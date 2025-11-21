# frozen_string_literal: true

class CreateCombatParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :combat_participants do |t|
      t.integer :character_id
      t.integer :initiative
      t.integer :initiative_modifier
      t.integer :current_hit_points
      t.integer :max_hit_points
      t.integer :temporary_hit_points
      t.integer :armor_class
      t.jsonb :conditions
      t.string :concentrating_on
      t.boolean :is_active
      t.boolean :defeated
      t.datetime :deleted_at
      t.integer :combat_id
      t.integer :encounter_monster_id
      t.integer :death_save_successes, null: false, default: 0
      t.integer :death_save_failures, null: false, default: 0
      t.integer :actions_used, null: false, default: 0
      t.integer :bonus_actions_used, null: false, default: 0
      t.integer :reactions_used, null: false, default: 0
      t.string :name
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :combat_participants, :discarded_at
  end
end