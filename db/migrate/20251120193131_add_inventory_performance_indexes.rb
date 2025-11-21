# frozen_string_literal: true

# Performance indexes for D&D 5e inventory and spell systems
# Adds GIN indexes for JSONB fields to optimize inventory searches,
# spell slot queries, and combat tracking lookups
class AddInventoryPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    # CharacterInventory JSONB indexes for fast inventory searches
    add_index :character_inventories, :inventory_grid, using: :gin,
              comment: 'Fast inventory grid searches for items and stacking'

    add_index :character_inventories, :equipped_items, using: :gin,
              comment: 'Fast equipped items lookups by slot'

    add_index :character_inventories, :currency, using: :gin,
              comment: 'Fast currency queries for spell material costs'

    add_index :character_inventories, :equipment_sets, using: :gin,
              comment: 'Fast equipment set switching and loadout queries'

    # CharacterCombatTracker JSONB indexes for combat state
    add_index :character_combat_trackers, :action_resources, using: :gin,
              comment: 'Fast action economy and attunement lookups'

    # CharacterSpellManager JSONB indexes for spell system
    add_index :character_spell_managers, :spell_slots, using: :gin,
              comment: 'Fast spell slot availability queries'

    add_index :character_spell_managers, :prepared_spells, using: :gin,
              comment: 'Fast prepared spell lookups'

    add_index :character_spell_managers, :known_spells, using: :gin,
              comment: 'Fast known spell queries for Sorcerers/Bards'

    add_index :character_spell_managers, :concentration, using: :gin,
              comment: 'Fast active concentration spell lookups'

    add_index :character_spell_managers, :known_metamagics, using: :gin,
              comment: 'Fast metamagic option queries for Sorcerers'
  end
end
