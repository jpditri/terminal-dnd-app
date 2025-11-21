# frozen_string_literal: true

class Monster < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :alignment, optional: true
  has_many :monster_abilities, dependent: :destroy
  has_many :encounter_monsters, dependent: :destroy
  has_many :encounters, through: :encounter_monsters

  validates :name, presence: true

  scope :recent, -> { all }
  scope :search_name, -> { all }
  scope :alignment_id_min, -> { all }
  scope :alignment_id_max, -> { all }
  scope :alignment_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end