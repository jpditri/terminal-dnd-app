# frozen_string_literal: true

class CreateGameSessionParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :game_session_participants do |t|
      t.timestamps
      t.datetime :discarded_at
    end
    add_index :game_session_participants, :discarded_at
  end
end