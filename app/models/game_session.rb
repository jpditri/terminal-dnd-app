# frozen_string_literal: true

class GameSession < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :campaign
  belongs_to :current_turn_player, optional: true
  has_one :ai_dm_context, dependent: :destroy
  has_many :game_session_participants, dependent: :destroy
  has_many :characters, through: :game_session_participants
  has_many :users, through: :game_session_participants
  has_many :session_recaps, dependent: :destroy
  has_many :combats, dependent: :destroy
  has_many :dice_rolls, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  has_many :ai_dm_suggestions, dependent: :nullify
  belongs_to :campaign

  validates :title, presence: true
  validates :campaign_id, presence: true

  scope :active, -> { all }
  scope :in_progress, -> { all }
  scope :recent, -> { all }
  scope :campaign_id_min, -> { all }
  scope :campaign_id_max, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end