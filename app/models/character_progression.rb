# frozen_string_literal: true

class CharacterProgression < ApplicationRecord
  belongs_to :character

  validates :character_id, presence: true, uniqueness: true

end