# frozen_string_literal: true

class ExportArchive < ApplicationRecord
  belongs_to :campaign
  belongs_to :user
  belongs_to :campaign
  belongs_to :user

  validates :archive_type, presence: true
  validates :status, presence: true
  validates :download_token, uniqueness: true
  validates :campaign_id, presence: true
  validates :user_id, presence: true

  scope :active, -> { all }
  scope :completed, -> { all }
  scope :failed, -> { all }
  scope :expired, -> { all }
  scope :not_expired, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :for_user, ->(user) { where(user: user) }

end