# frozen_string_literal: true

class CampaignMembership < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :user
  belongs_to :campaign
  belongs_to :campaign
  belongs_to :user

  validates :campaign_id, presence: true
  validates :user_id, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :user_id_min, -> { all }
  scope :user_id_max, -> { all }
  scope :user_id_range, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end