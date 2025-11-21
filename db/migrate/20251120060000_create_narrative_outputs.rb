# frozen_string_literal: true

class CreateNarrativeOutputs < ActiveRecord::Migration[7.1]
  def change
    create_table :narrative_outputs do |t|
      t.references :terminal_session, null: false, foreign_key: true
      t.text :content, null: false
      t.string :content_type, null: false, default: 'narrative'
      t.jsonb :clickable_elements, default: []
      t.text :rendered_html

      t.timestamps
    end

    add_index :narrative_outputs, :content_type
    add_index :narrative_outputs, :created_at
  end
end
