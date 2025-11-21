class CreateDmPendingActions < ActiveRecord::Migration[7.1]
  def change
    create_table :dm_pending_actions, id: :integer do |t|

      t.timestamps
    end
  end
end
