# frozen_string_literal: true

class CharacterAiAssistant < ApplicationRecord
  belongs_to :character

  validates :character_id, presence: true, uniqueness: true
  validates :ai_usage_tokens, numericality: true

  scope :enabled, -> { all }
  scope :over_limit, -> { all }
  scope :under_limit, -> { all }

end