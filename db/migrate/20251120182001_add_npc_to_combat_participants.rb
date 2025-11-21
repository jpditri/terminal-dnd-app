class AddNpcToCombatParticipants < ActiveRecord::Migration[7.1]
  def change
    add_reference :combat_participants, :npc, null: true, foreign_key: true, type: :integer
  end
end
