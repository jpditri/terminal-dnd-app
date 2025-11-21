# frozen_string_literal: true

class CreateQuickActions < ActiveRecord::Migration[7.1]
  def change
    create_table :quick_actions do |t|
      t.references :terminal_session, null: false, foreign_key: true
      t.string :label, null: false
      t.string :action_type, null: false
      t.string :target_id
      t.jsonb :params, default: {}
      t.string :tooltip
      t.string :keyboard_shortcut
      t.boolean :requires_roll, default: false
      t.string :skill_check
      t.integer :dc
      t.boolean :is_available, default: true
      t.integer :sort_order, default: 0
      t.datetime :cooldown_until

      t.timestamps
    end

    add_index :quick_actions, :action_type
    add_index :quick_actions, :is_available
  end
end
