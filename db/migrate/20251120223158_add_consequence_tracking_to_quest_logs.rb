class AddConsequenceTrackingToQuestLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :quest_logs, :presentation_count, :integer, default: 0
    add_column :quest_logs, :last_presented_at, :datetime
    add_column :quest_logs, :consequence_applied, :boolean, default: false
    add_column :quest_logs, :escalation_level, :integer, default: 0
    add_column :quest_logs, :resolution_type, :string
  end
end
