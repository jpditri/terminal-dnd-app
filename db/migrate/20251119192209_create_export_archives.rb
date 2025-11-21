# frozen_string_literal: true

class CreateExportArchives < ActiveRecord::Migration[7.1]
  def change
    create_table :export_archives do |t|
      t.integer :campaign_id, null: false
      t.integer :user_id, null: false
      t.string :archive_type, null: false
      t.string :status
      t.timestamps
    end
  end
end