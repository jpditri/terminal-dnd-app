# frozen_string_literal: true

class CharacterNote < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :character

  validates :title, presence: true
  validates :note_category, presence: true
  validate :session_fields_for_journal
  validate :npc_fields_for_relationship

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :character_id_min, -> { all }
  scope :character_id_max, -> { all }
  scope :character_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end