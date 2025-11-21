# frozen_string_literal: true

class CreateCharacterFeats < ActiveRecord::Migration[7.1]
  def change
    create_table :character_feats do |t|
      t.integer :character_id, null: false
      t.integer :feat_id, null: false
      t.integer :level_gained
      t.timestamps
    end
  end
end