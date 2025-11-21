# frozen_string_literal: true

class Encounter < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :campaign, optional: true
  belongs_to :game_session, optional: true
  has_many :encounter_monsters, dependent: :destroy
  has_many :monsters, through: :encounter_monsters
  has_many :combats, dependent: :destroy
  belongs_to :campaign

  validates :name, presence: true
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