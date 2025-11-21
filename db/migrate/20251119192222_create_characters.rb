# frozen_string_literal: true

class CreateCharacters < ActiveRecord::Migration[7.1]
  def change
    create_table :characters do |t|
      t.string :name
      t.integer :level
      t.integer :experience
      t.integer :proficiency_bonus
      t.integer :strength
      t.integer :dexterity
      t.integer :constitution
      t.integer :intelligence
      t.integer :wisdom
      t.integer :charisma
      t.integer :hit_points_current
      t.integer :hit_points_max
      t.integer :temporary_hit_points
      t.integer :armor_class
      t.integer :initiative_bonus
      t.integer :speed
      t.string :alignment
      t.text :personality_traits
      t.text :ideals
      t.text :bonds
      t.text :flaws
      t.text :backstory
      t.jsonb :skills
      t.jsonb :proficiencies
      t.jsonb :conditions
      t.string :avatar_url
      t.string :visibility
      t.datetime :deleted_at
      t.integer :user_id
      t.integer :campaign_id
      t.integer :race_id
      t.integer :character_class_id
      t.integer :background_id
      t.text :character_voice
      t.jsonb :ai_personality_profile, default: {}
      t.jsonb :catchphrases, default: []
      t.jsonb :homebrew_modifications, default: {}
      t.jsonb :custom_features, default: []
      t.jsonb :house_rules, default: {}
      t.jsonb :quick_actions, default: []
      t.jsonb :favorite_spells, default: []
      t.jsonb :combat_tactics, default: []
      t.jsonb :theme_preferences, default: {}
      t.string :portrait_url
      t.string :token_url
      t.text :last_session_notes
      t.integer :session_count, default: 0
      t.decimal :total_playtime_hours, default: 0
      t.jsonb :faction_affiliations, null: false, default: {}
      t.jsonb :faction_reputations, null: false, default: {}
      t.integer :current_hp
      t.integer :max_hp
      t.integer :temporary_hp, null: false, default: 0
      t.integer :death_save_successes, null: false, default: 0
      t.integer :death_save_failures, null: false, default: 0
      t.jsonb :spell_slots, null: false, default: {}
      t.integer :concentration_spell_id
      t.jsonb :damage_resistances, null: false, default: []
      t.jsonb :damage_immunities, null: false, default: []
      t.jsonb :damage_vulnerabilities, null: false, default: []
      t.jsonb :active_effects, default: []
      t.jsonb :resistances, default: []
      t.jsonb :immunities, default: []
      t.jsonb :vulnerabilities, default: []
      t.integer :hit_dice_used, null: false, default: 0
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :characters, :discarded_at
  end
end