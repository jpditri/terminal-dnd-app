# frozen_string_literal: true

class CreateCharacterProgressions < ActiveRecord::Migration[7.1]
  def change
    create_table :character_progressions do |t|
      t.integer :character_id, null: false
      t.jsonb :level_history, default: []
      t.jsonb :multiclass_levels, default: {}
      t.jsonb :feat_choices, default: []
      t.jsonb :asi_choices, default: []
      t.jsonb :subclass_features, default: {}
      t.jsonb :milestone_tracker, default: []
      t.integer :next_level_xp
      t.string :progression_type
      t.jsonb :planned_levels, default: []
      t.jsonb :xp_history, null: false, default: []
      t.timestamps
    end
  end
end