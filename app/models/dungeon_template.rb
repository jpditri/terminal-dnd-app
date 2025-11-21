# frozen_string_literal: true

class DungeonTemplate < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :created_by_user
  has_many :generated_dungeons, dependent: :nullify

  validates :name, presence: true
  validates :min_party_level, numericality: true
  validates :max_party_level, numericality: true
  validates :room_count_min, numericality: true
  validates :room_count_max, numericality: true
  validate :max_level_greater_than_min_level
  validate :max_rooms_greater_than_min_rooms

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :search_name, -> { all }
  scope :search_description, -> { all }
  scope :min_party_level_min, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end