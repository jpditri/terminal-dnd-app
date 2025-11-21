# frozen_string_literal: true

class AiContext < ApplicationRecord
  belongs_to :character
  belongs_to :solo_session, optional: true

  validates :character_id, presence: true
  validates :context_version, numericality: true

  scope :for_character, -> { all }
  scope :recent, -> { all }
  scope :active, -> { all }

end