# frozen_string_literal: true

class SoloSession < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :user
  belongs_to :campaign
  belongs_to :character
  belongs_to :adventure_template, optional: true
  belongs_to :combat, optional: true
  has_one :latest_game_state
  has_many :solo_game_states, dependent: :destroy
  has_many :ai_conversations, dependent: :destroy
  belongs_to :campaign
  belongs_to :user

  validates :campaign_id, presence: true
  validates :user_id, presence: true

  scope :active, -> { all }
  scope :in_progress, -> { all }
  scope :recent, -> { all }
  scope :user_id_min, -> { all }
  scope :user_id_max, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end