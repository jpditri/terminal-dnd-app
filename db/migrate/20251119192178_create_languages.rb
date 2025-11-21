# frozen_string_literal: true

class CreateLanguages < ActiveRecord::Migration[7.1]
  def change
    create_table :languages do |t|
      t.string :name
      t.string :script
      t.text :typical_speakers
      t.text :description
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :languages, :discarded_at
  end
end