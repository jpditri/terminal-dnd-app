# frozen_string_literal: true

class CreateQuestObjectives < ActiveRecord::Migration[7.1]
  def change
    create_table :quest_objectives do |t|
      t.string :description
      t.integer :order_index
      t.boolean :completed
      t.boolean :optional
      t.integer :progress_current
      t.integer :progress_target
      t.datetime :deleted_at
      t.integer :quest_log_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :quest_objectives, :discarded_at
  end
end