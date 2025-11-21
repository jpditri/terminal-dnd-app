# frozen_string_literal: true

class CampaignNote < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :campaign
  belongs_to :user
  belongs_to :game_session, optional: true
  belongs_to :campaign
  belongs_to :user

  validates :title, presence: true
  validates :campaign_id, presence: true
  validates :user_id, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :campaign_id_min, -> { all }
  scope :campaign_id_max, -> { all }
  scope :campaign_id_range, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end