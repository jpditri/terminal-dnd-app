# frozen_string_literal: true

class Race < ApplicationRecord
  include Discard::Model

  has_paper_trail

  validates :name, presence: true

  scope :recent, -> { all }
  scope :search_name, -> { all }
  scope :speed_min, -> { all }
  scope :speed_max, -> { all }
  scope :speed_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end