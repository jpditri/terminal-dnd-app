# frozen_string_literal: true

class CombatParticipant < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :combat
  belongs_to :character, optional: true
  belongs_to :encounter_monster, optional: true
  belongs_to :npc, optional: true
  has_many :combat_actions, dependent: :destroy

  # Validation: exactly one combatant type must be present
  validate :one_combatant_present

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :combat_id_min, -> { all }
  scope :combat_id_max, -> { all }
  scope :combat_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

  # Helper methods to get the actual combatant entity
  def combatant
    character || encounter_monster || npc
  end

  def combatant_name
    combatant&.name || 'Unknown'
  end

  def combatant_type
    return 'Player' if character.present?
    return 'Monster' if encounter_monster.present?
    return 'NPC' if npc.present?
    'Unknown'
  end

  private

  def one_combatant_present
    present_count = [character_id, encounter_monster_id, npc_id].compact.count
    if present_count == 0
      errors.add(:base, 'Must have either a character, encounter_monster, or npc')
    elsif present_count > 1
      errors.add(:base, 'Can only have one of character, encounter_monster, or npc')
    end
  end
end