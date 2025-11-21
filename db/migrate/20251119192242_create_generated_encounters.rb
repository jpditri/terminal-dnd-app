# frozen_string_literal: true

class CreateGeneratedEncounters < ActiveRecord::Migration[7.1]
  def change
    create_table :generated_encounters do |t|
      t.integer :campaign_id
      t.string :name
      t.integer :party_level
      t.integer :party_size
      t.string :difficulty_rating
      t.integer :total_xp
      t.jsonb :monsters_data
      t.jsonb :terrain_features
      t.jsonb :treasure
      t.text :narrative_hook
      t.text :tactics
      t.datetime :generated_at
      t.integer :used_in_encounter_id
      t.datetime :deleted_at
      t.integer :encounter_template_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :generated_encounters, :discarded_at
  end
end