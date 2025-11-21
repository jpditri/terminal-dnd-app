# frozen_string_literal: true

class CombatEncounter < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :campaign
  belongs_to :game_session, optional: true
  belongs_to :current_turn_combatant, optional: true
  has_many :combatants, dependent: :destroy
  has_many :damage_logs, dependent: :destroy
  has_many :healing_logs, dependent: :destroy
  belongs_to :campaign

  validates :campaign_id, presence: true

  scope :active, -> { all }
  scope :preparing, -> { all }
  scope :completed, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end