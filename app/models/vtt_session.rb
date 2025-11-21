# frozen_string_literal: true

class VttSession < ApplicationRecord
  belongs_to :game_session
  belongs_to :campaign
  belongs_to :location, optional: true
  belongs_to :encounter, optional: true
  has_one :vtt_map, dependent: :destroy
  has_many :vtt_tokens, dependent: :destroy
  belongs_to :campaign

  validates :grid_size, numericality: true
  validates :zoom_level, numericality: true
  validates :campaign_id, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }

end