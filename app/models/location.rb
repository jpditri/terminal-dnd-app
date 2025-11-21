# frozen_string_literal: true

class Location < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :world
  belongs_to :parent_location, optional: true
  has_many :child_locations, dependent: :nullify
  has_many :npcs, dependent: :nullify
  has_many :encounters, dependent: :nullify
  has_many :factions, dependent: :nullify

  validates :name, presence: true
  validates :danger_level, numericality: true
  validates :population, numericality: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :world_id_min, -> { all }
  scope :world_id_max, -> { all }
  scope :world_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end