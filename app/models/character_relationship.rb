# frozen_string_literal: true

class CharacterRelationship < ApplicationRecord
  belongs_to :character
  belongs_to :related_character, optional: true

  validates :relationship_type, presence: true
  validates :bond_strength, presence: true, numericality: true
  validates :related_character_id, uniqueness: true
  validate :cannot_relate_to_self
  validate :must_have_target

  scope :pc_relationships, -> { all }
  scope :npc_relationships, -> { all }
  scope :strong_bonds, -> { all }
  scope :weak_bonds, -> { all }
  scope :by_strength, -> { all }

end