class AddSessionTokenToTerminalSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :terminal_sessions, :session_token, :string
  end
end
