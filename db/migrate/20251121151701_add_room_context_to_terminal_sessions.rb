class AddRoomContextToTerminalSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :terminal_sessions, :current_room, :string, default: 'lobby'
    add_column :terminal_sessions, :game_started_at, :datetime
    add_column :terminal_sessions, :character_locked, :boolean, default: false
    add_column :terminal_sessions, :room_history, :jsonb, default: []
  end
end
