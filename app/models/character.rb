# frozen_string_literal: true

class Character < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :user
  belongs_to :campaign, optional: true
  belongs_to :race, optional: true
  belongs_to :character_class, optional: true
  belongs_to :background, optional: true
  has_one :character_inventory, dependent: :destroy
  has_one :character_spell_manager, dependent: :destroy
  has_one :ai_assistant, dependent: :destroy
  has_one :ai_context, dependent: :destroy
  has_one :character_progression, dependent: :destroy
  has_one :character_combat_tracker, dependent: :destroy
  has_many :character_spells, dependent: :destroy
  has_many :spells, through: :character_spells
  has_many :character_items, dependent: :destroy
  has_many :items, through: :character_items
  has_many :character_feats, dependent: :destroy
  has_many :feats, through: :character_feats
  has_many :character_notes, dependent: :destroy
  has_many :weapons, dependent: :destroy
  has_many :quest_logs, dependent: :destroy
  has_many :solo_sessions, dependent: :destroy
  has_many :character_relationships, dependent: :destroy
  has_many :related_characters, through: :character_relationships
  has_many :inverse_relationships

  validates :name, presence: true
  validates :user_id, presence: true
  # campaign_id validation removed - optional for terminal/solo play

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :search_name, -> { all }
  scope :user_id_min, -> { all }
  scope :user_id_max, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

  # D&D 5e ability score modifiers
  def strength_modifier
    calculate_modifier(strength)
  end

  def dexterity_modifier
    calculate_modifier(dexterity)
  end

  def constitution_modifier
    calculate_modifier(constitution)
  end

  def intelligence_modifier
    calculate_modifier(intelligence)
  end

  def wisdom_modifier
    calculate_modifier(wisdom)
  end

  def charisma_modifier
    calculate_modifier(charisma)
  end

  def calculated_armor_class
    # Base AC 10 + dexterity modifier
    # TODO: Add armor bonuses when equipment system is implemented
    10 + dexterity_modifier
  end

  private

  def calculate_modifier(score)
    return 0 if score.nil?
    ((score - 10) / 2).floor
  end
end