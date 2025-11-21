# frozen_string_literal: true

class CreateFactionMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :faction_memberships do |t|
      t.integer :character_id
      t.string :rank
      t.string :title
      t.integer :reputation
      t.datetime :joined_at
      t.datetime :left_at
      t.string :status
      t.jsonb :contributions
      t.datetime :deleted_at
      t.integer :faction_id
      t.integer :npc_id
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :faction_memberships, :discarded_at
  end
end