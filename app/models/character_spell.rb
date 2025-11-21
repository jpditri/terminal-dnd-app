# frozen_string_literal: true

class CharacterSpell < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :character
  belongs_to :spell

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :character_id_min, -> { all }
  scope :character_id_max, -> { all }
  scope :character_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end