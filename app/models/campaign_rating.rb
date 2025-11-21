# frozen_string_literal: true

class CampaignRating < ApplicationRecord
  include Discard::Model

  belongs_to :campaign
  belongs_to :user
  belongs_to :campaign
  belongs_to :user

  validates :campaign_id, presence: true
  validates :user_id, presence: true
  validates :rating, presence: true
  validate :user_must_be_member_or_former_member
  validate :one_rating_per_user_per_campaign
  validates :campaign_id, presence: true
  validates :user_id, presence: true

  scope :recent, -> { all }
  scope :for_campaign, -> { all }
  scope :for_user, -> { all }
  scope :high_rated, -> { all }
  scope :with_reviews, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end