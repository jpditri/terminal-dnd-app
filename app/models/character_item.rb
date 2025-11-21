# frozen_string_literal: true

class CharacterItem < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :character
  belongs_to :item

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :in_slot, -> { all }
  scope :equipped_in_slots, -> { all }
  scope :character_id_min, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end