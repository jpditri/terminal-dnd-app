# frozen_string_literal: true

class FactionRelationship < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :faction

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :faction_id_min, -> { all }
  scope :faction_id_max, -> { all }
  scope :faction_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end