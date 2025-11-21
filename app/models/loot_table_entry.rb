# frozen_string_literal: true

class LootTableEntry < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :loot_table
  belongs_to :item, optional: true

  validates :treasure_type, presence: true
  validates :weight, numericality: true

  scope :by_type, -> { all }
  scope :ordered_by_weight, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end