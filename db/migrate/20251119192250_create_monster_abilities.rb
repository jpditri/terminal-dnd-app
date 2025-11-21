# frozen_string_literal: true

class CreateMonsterAbilities < ActiveRecord::Migration[7.1]
  def change
    create_table :monster_abilities do |t|
      t.string :name
      t.string :ability_type
      t.text :description
      t.integer :attack_bonus
      t.string :damage_dice
      t.string :damage_type
      t.integer :save_dc
      t.string :save_ability
      t.string :recharge
      t.datetime :deleted_at
      t.integer :monster_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :monster_abilities, :discarded_at
  end
end