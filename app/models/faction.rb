# frozen_string_literal: true

class Faction < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :campaign
  belongs_to :world, optional: true
  belongs_to :alignment, optional: true
  belongs_to :headquarters_location, optional: true
  belongs_to :leader_npc, optional: true
  has_many :npcs, dependent: :nullify
  has_many :faction_memberships, dependent: :destroy
  has_many :faction_relationships, dependent: :destroy
  belongs_to :campaign

  validates :name, presence: true
  validates :power_level, numericality: true
  validates :campaign_id, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :campaign_id_min, -> { all }
  scope :campaign_id_max, -> { all }
  scope :campaign_id_range, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end