# frozen_string_literal: true

class WorldLoreEntry < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :world

  validates :title, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :world_id_min, -> { all }
  scope :world_id_max, -> { all }
  scope :world_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end