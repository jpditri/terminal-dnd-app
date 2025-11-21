# frozen_string_literal: true

class CreateAlignments < ActiveRecord::Migration[7.1]
  def change
    create_table :alignments do |t|
      t.string :name
      t.string :code
      t.string :axis_law_chaos
      t.string :axis_good_evil
      t.text :description
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :alignments, :discarded_at
  end
end