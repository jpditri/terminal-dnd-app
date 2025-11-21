# frozen_string_literal: true

class CreateFeats < ActiveRecord::Migration[7.1]
  def change
    create_table :feats do |t|
      t.string :name, null: false
      t.text :description
      t.text :prerequisites
      t.jsonb :ability_score_increases, default: {}
      t.jsonb :benefits, default: {}
      t.string :source, default: "SRD"
      t.timestamps
    end
  end
end