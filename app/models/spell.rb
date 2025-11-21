# frozen_string_literal: true

class Spell < ApplicationRecord
  include Discard::Model

  has_paper_trail

  validates :name, presence: true

  scope :recent, -> { all }
  scope :search_name, -> { all }
  scope :level_min, -> { all }
  scope :level_max, -> { all }
  scope :level_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end