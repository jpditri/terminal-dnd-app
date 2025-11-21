# frozen_string_literal: true

class Npc < ApplicationRecord
  include Discard::Model
  include CombatEntity

  has_paper_trail

  belongs_to :campaign
  belongs_to :world, optional: true
  belongs_to :faction, optional: true
  belongs_to :location, optional: true
  belongs_to :race, optional: true
  belongs_to :character_class, optional: true
  belongs_to :alignment, optional: true
  has_many :npc_interactions, dependent: :destroy
  has_many :faction_memberships, dependent: :destroy
  has_many :combat_participants, dependent: :destroy

  validates :name, presence: true
  validates :age, numericality: true

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