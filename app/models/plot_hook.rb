# frozen_string_literal: true

class PlotHook < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :campaign
  belongs_to :created_by_user
  belongs_to :converted_to_quest, optional: true
  belongs_to :campaign

  validates :title, presence: true
  validates :suggested_level_min, numericality: true
  validates :suggested_level_max, numericality: true
  validate :max_level_greater_than_min_level
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