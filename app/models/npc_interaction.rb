# frozen_string_literal: true

class NpcInteraction < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :npc

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :npc_id_min, -> { all }
  scope :npc_id_max, -> { all }
  scope :npc_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end