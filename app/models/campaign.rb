# frozen_string_literal: true

class Campaign < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :world, optional: true
  belongs_to :dm, optional: true
  belongs_to :template, optional: true
  has_one :ai_dm_assistant, dependent: :destroy
  has_many :campaign_memberships, dependent: :destroy
  has_many :members, through: :campaign_memberships
  has_many :characters, dependent: :destroy
  has_many :game_sessions, dependent: :destroy
  has_many :campaign_notes, dependent: :destroy
  has_many :solo_sessions, dependent: :destroy
  has_many :quest_logs, dependent: :destroy
  has_many :maps, dependent: :destroy
  has_many :encounters, dependent: :destroy
  has_many :npcs, dependent: :destroy
  has_many :combats, through: :game_sessions
  has_many :campaign_join_requests, dependent: :destroy
  has_many :campaign_ratings, dependent: :destroy
  has_many :export_archives, dependent: :destroy

  validates :name, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :search_name, -> { all }
  scope :search_description, -> { all }
  scope :public_campaigns, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end