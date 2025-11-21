# frozen_string_literal: true

class CampaignJoinRequest < ApplicationRecord
  include Discard::Model

  belongs_to :campaign
  belongs_to :user
  belongs_to :campaign
  belongs_to :user

  validates :campaign_id, presence: true
  validates :user_id, presence: true
  validates :status, presence: true
  validate :user_not_already_member
  validate :no_duplicate_pending_requests
  validate :user_not_blocked
  validates :campaign_id, presence: true
  validates :user_id, presence: true

  scope :pending, -> { all }
  scope :approved, -> { all }
  scope :declined, -> { all }
  scope :for_campaign, -> { all }
  scope :for_user, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end