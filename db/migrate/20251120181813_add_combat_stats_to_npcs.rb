class AddCombatStatsToNpcs < ActiveRecord::Migration[7.1]
  def change
    # D&D 5e Ability Scores (3-20 range, 10 is average)
    add_column :npcs, :strength, :integer, default: 10
    add_column :npcs, :dexterity, :integer, default: 10
    add_column :npcs, :constitution, :integer, default: 10
    add_column :npcs, :intelligence, :integer, default: 10
    add_column :npcs, :wisdom, :integer, default: 10
    add_column :npcs, :charisma, :integer, default: 10

    # Combat Stats
    add_column :npcs, :armor_class, :integer, default: 10
    add_column :npcs, :hit_points, :integer
    add_column :npcs, :max_hit_points, :integer
    add_column :npcs, :hit_dice, :string
    add_column :npcs, :level, :integer, default: 1
    add_column :npcs, :proficiency_bonus, :integer, default: 2

    # Advanced Combat Features (JSONB for flexibility)
    add_column :npcs, :saving_throws, :jsonb, default: {}
    add_column :npcs, :skills, :jsonb, default: {}

    # Damage and Condition Modifiers
    add_column :npcs, :damage_resistances, :text
    add_column :npcs, :damage_immunities, :text
    add_column :npcs, :condition_immunities, :text

    # Movement and Challenge
    add_column :npcs, :speed, :integer, default: 30
    add_column :npcs, :challenge_rating, :decimal, precision: 4, scale: 2

    # Initiative tracking for combat
    add_column :npcs, :initiative, :integer
    add_column :npcs, :conditions, :text
  end
end
