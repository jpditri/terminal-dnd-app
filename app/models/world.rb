# frozen_string_literal: true

class World < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :creator, optional: true
  has_many :campaigns, dependent: :destroy
  has_many :world_lore_entries, dependent: :destroy

  validates :name, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :search_name, -> { all }
  scope :search_description, -> { all }
  scope :creator_id_min, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end