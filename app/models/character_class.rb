# frozen_string_literal: true

class CharacterClass < ApplicationRecord
  include Discard::Model

  has_paper_trail

  validates :name, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :search_name, -> { all }
  scope :hit_die_min, -> { all }
  scope :hit_die_max, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end