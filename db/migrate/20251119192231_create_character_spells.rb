# frozen_string_literal: true

class CreateCharacterSpells < ActiveRecord::Migration[7.1]
  def change
    create_table :character_spells do |t|
      t.boolean :known
      t.boolean :prepared
      t.boolean :always_prepared
      t.integer :character_id
      t.integer :spell_id
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :character_spells, :discarded_at
  end
end