# frozen_string_literal: true

class MonsterAbility < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :monster

  validates :name, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :monster_id_min, -> { all }
  scope :monster_id_max, -> { all }
  scope :monster_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end