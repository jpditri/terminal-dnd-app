# frozen_string_literal: true

class GeneratedDungeon < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :dungeon_template
  belongs_to :location

  validates :name, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :dungeon_template_id_min, -> { all }
  scope :dungeon_template_id_max, -> { all }
  scope :dungeon_template_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end