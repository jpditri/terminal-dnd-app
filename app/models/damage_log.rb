# frozen_string_literal: true

class DamageLog < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :combat_encounter
  belongs_to :source, polymorphic: true, optional: true
  belongs_to :target, polymorphic: true, optional: true

  scope :by_round, -> { all }
  scope :recent, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end