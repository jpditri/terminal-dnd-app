# frozen_string_literal: true

class Weapon < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :character, optional: true
  belongs_to :item, optional: true

  validates :name, presence: true
  validates :damage_dice, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :by_damage_type, -> { all }
  scope :finesse_weapons, -> { all }
  scope :versatile_weapons, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end