# frozen_string_literal: true

class AiDmContext < ApplicationRecord
  belongs_to :ai_dm_assistant
  belongs_to :game_session

  validates :ai_dm_assistant_id, presence: true
  validates :game_session_id, presence: true

  scope :active_session, -> { all }
  scope :recent, -> { all }

end