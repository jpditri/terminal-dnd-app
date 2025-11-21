# frozen_string_literal: true

class Token < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :map
  belongs_to :character, optional: true
  belongs_to :encounter_monster, optional: true

  validates :name, presence: true
  validates :grid_x, presence: true, numericality: true

  scope :recent, -> { all }
  scope :map_id_min, -> { all }
  scope :map_id_max, -> { all }
  scope :map_id_range, -> { all }
  scope :character_id_min, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end