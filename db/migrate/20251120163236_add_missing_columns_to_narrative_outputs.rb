class AddMissingColumnsToNarrativeOutputs < ActiveRecord::Migration[7.1]
  def change
    add_column :narrative_outputs, :memory_hints, :jsonb
    add_column :narrative_outputs, :speaker, :string
    add_column :narrative_outputs, :related_room_id, :integer
    add_column :narrative_outputs, :related_npc_id, :integer
  end
end
