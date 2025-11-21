class AddExecutionTimeMsToDmActionAuditLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :dm_action_audit_logs, :execution_time_ms, :integer
  end
end
