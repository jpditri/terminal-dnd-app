# frozen_string_literal: true

class QuestTemplate < ApplicationRecord
  validates :name, presence: true

  scope :by_type, -> { all }
  scope :by_difficulty, -> { all }
  scope :by_category, -> { all }
  scope :for_party_level, -> { all }

end