# frozen_string_literal: true

class CreateTerminalSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :terminal_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :mode, default: 'exploration'
      t.boolean :active, default: true
      t.references :character, foreign_key: true
      t.references :dungeon_map, foreign_key: { to_table: :maps }
      t.references :solo_session, foreign_key: true
      t.string :map_render_mode, default: 'ascii'
      t.boolean :show_map_panel, default: true
      t.jsonb :command_history, default: []
      t.jsonb :settings, default: {}

      # Discord integration
      t.string :discord_channel_id
      t.string :discord_guild_id
      t.string :discord_thread_id

      t.timestamps
    end

    add_index :terminal_sessions, :discord_channel_id
    add_index :terminal_sessions, :active
  end
end
