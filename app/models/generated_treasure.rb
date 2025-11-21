# frozen_string_literal: true

class GeneratedTreasure < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :loot_table
  belongs_to :campaign, optional: true
  belongs_to :character, optional: true
  belongs_to :campaign

  validates :generated_at, presence: true
  validates :treasure_data, presence: true
  validates :campaign_id, presence: true

  scope :recent, -> { all }
  scope :for_campaign, -> { all }
  scope :for_character, -> { all }
  scope :this_week, -> { all }
  scope :this_month, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end