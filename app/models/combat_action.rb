# frozen_string_literal: true

class CombatAction < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :combat
  belongs_to :combat_participant
  belongs_to :spell, optional: true
  belongs_to :item, optional: true
  has_many :dice_rolls, dependent: :destroy

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :combat_id_min, -> { all }
  scope :combat_id_max, -> { all }
  scope :combat_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end