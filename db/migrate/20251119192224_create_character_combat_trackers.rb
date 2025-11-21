# frozen_string_literal: true

class CreateCharacterCombatTrackers < ActiveRecord::Migration[7.1]
  def change
    create_table :character_combat_trackers do |t|
      t.integer :character_id, null: false
      t.jsonb :action_resources, default: {}
      t.jsonb :death_saves
      t.jsonb :conditions, default: []
      t.jsonb :resistances, default: []
      t.jsonb :immunities, default: []
      t.jsonb :vulnerabilities, default: []
      t.integer :temp_hp, default: 0
      t.integer :exhaustion_level, default: 0
      t.integer :initiative_roll
      t.boolean :has_reaction, default: true
      t.boolean :has_bonus_action, default: true
      t.timestamps
    end
  end
end