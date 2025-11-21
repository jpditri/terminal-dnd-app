# frozen_string_literal: true

class CreateCharacterSpellManagers < ActiveRecord::Migration[7.1]
  def change
    create_table :character_spell_managers do |t|
      t.integer :character_id, null: false
      t.jsonb :spell_slots, default: {}
      t.jsonb :prepared_spells, default: []
      t.jsonb :known_spells, default: []
      t.jsonb :ritual_spells, default: []
      t.jsonb :spell_book, default: []
      t.string :spellcasting_ability
      t.integer :spell_save_dc
      t.integer :spell_attack_bonus
      t.integer :cantrips_known, default: 0
      t.jsonb :concentration, default: {}
      t.integer :lock_version, null: false, default: 0
      t.integer :sorcery_points_max, default: 0
      t.integer :sorcery_points_current, default: 0
      t.jsonb :known_metamagics, default: []
      t.jsonb :metamagic_options, default: {}
      t.integer :wild_magic_surge_count, default: 0
      t.timestamps
    end
  end
end