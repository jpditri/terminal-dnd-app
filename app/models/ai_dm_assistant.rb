# frozen_string_literal: true

class AiDmAssistant < ApplicationRecord
  include Discard::Model

  belongs_to :campaign
  has_many :ai_dm_suggestions, dependent: :destroy
  has_many :ai_dm_contexts, dependent: :destroy
  has_many :ai_dm_overrides, dependent: :destroy
  belongs_to :campaign

  validates :campaign_id, presence: true
  validates :campaign_id, presence: true

  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end