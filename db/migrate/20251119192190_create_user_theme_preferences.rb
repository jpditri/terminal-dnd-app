# frozen_string_literal: true

class CreateUserThemePreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :user_theme_preferences do |t|
      t.integer :user_id, null: false
      t.string :primary_color
      t.string :secondary_color
      t.string :accent_color
      t.string :background_color
      t.string :text_color
      t.boolean :dark_mode, null: false
      t.boolean :high_contrast, null: false
      t.boolean :reduced_motion, null: false
      t.string :font_size, default: "medium"
      t.timestamps
    end
  end
end