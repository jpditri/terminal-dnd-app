class AddWorldStateToCampaigns < ActiveRecord::Migration[7.1]
  def change
    add_column :campaigns, :world_state, :jsonb, default: {}
  end
end
