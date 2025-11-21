# frozen_string_literal: true

class CharacterFeat < ApplicationRecord
  belongs_to :character
  belongs_to :feat

  validates :character_id, uniqueness: true
  validates :level_gained, numericality: true

  scope :by_level, -> { all }
  scope :at_level, -> { all }

end