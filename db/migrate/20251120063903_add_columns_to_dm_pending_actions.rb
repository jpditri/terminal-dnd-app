class AddColumnsToDmPendingActions < ActiveRecord::Migration[7.1]
  def change
    add_reference :dm_pending_actions, :terminal_session, null: false, foreign_key: true
    add_reference :dm_pending_actions, :character, null: true, foreign_key: true
    add_reference :dm_pending_actions, :user, null: false, foreign_key: true

    add_column :dm_pending_actions, :tool_name, :string, null: false
    add_column :dm_pending_actions, :parameters, :jsonb, default: {}
    add_column :dm_pending_actions, :description, :text
    add_column :dm_pending_actions, :dm_reasoning, :text

    add_column :dm_pending_actions, :status, :string, default: 'pending', null: false
    add_column :dm_pending_actions, :expires_at, :datetime
    add_column :dm_pending_actions, :reviewed_at, :datetime
    add_column :dm_pending_actions, :reviewed_by, :bigint
    add_column :dm_pending_actions, :player_response, :text

    add_column :dm_pending_actions, :execution_result, :jsonb
    add_column :dm_pending_actions, :error_message, :text

    add_column :dm_pending_actions, :batch_id, :string
    add_column :dm_pending_actions, :batch_order, :integer

    add_column :dm_pending_actions, :discarded_at, :datetime

    add_index :dm_pending_actions, :status
    add_index :dm_pending_actions, :expires_at
    add_index :dm_pending_actions, :batch_id
    add_index :dm_pending_actions, :discarded_at
  end
end
