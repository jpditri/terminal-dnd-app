# frozen_string_literal: true

class ActiveEffect < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :combatant

  scope :conditions, -> { all }
  scope :buffs, -> { all }
  scope :debuffs, -> { all }
  scope :concentration, -> { all }
  scope :regeneration, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end