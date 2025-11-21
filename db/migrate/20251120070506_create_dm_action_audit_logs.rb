class CreateDmActionAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :dm_action_audit_logs do |t|
      t.references :terminal_session, null: false, foreign_key: true
      t.references :character, null: true, foreign_key: true
      t.references :dm_pending_action, null: true, foreign_key: true

      t.string :tool_name, null: false
      t.jsonb :parameters, default: {}
      t.jsonb :result, default: {}

      t.string :execution_status, null: false, default: 'executed'
      t.jsonb :state_before, default: {}
      t.jsonb :state_after, default: {}

      t.integer :conversation_turn
      t.string :trigger_source

      t.timestamps
    end

    add_index :dm_action_audit_logs, :execution_status
    add_index :dm_action_audit_logs, :conversation_turn
    add_index :dm_action_audit_logs, :tool_name
    add_index :dm_action_audit_logs, [:terminal_session_id, :conversation_turn]
  end
end
