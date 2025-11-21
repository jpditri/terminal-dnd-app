class AddCampaignToTerminalSessions < ActiveRecord::Migration[7.1]
  def change
    add_reference :terminal_sessions, :campaign, foreign_key: true, type: :integer
  end
end
