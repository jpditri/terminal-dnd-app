# frozen_string_literal: true

class EncounterMonster < ApplicationRecord
  include Discard::Model
  include CombatEntity

  has_paper_trail

  belongs_to :encounter
  belongs_to :monster

  # Delegate ability scores and other monster attributes to the monster template
  delegate :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma,
           :armor_class, :hit_dice, :speed, :challenge_rating,
           :damage_resistances, :damage_immunities, :condition_immunities,
           :saving_throws, :skills, to: :monster

  # Override hit_points to use current_hit_points from EncounterMonster
  def hit_points
    current_hit_points
  end

  def hit_points=(value)
    self.current_hit_points = value
  end

  # Override defeated? to use the defeated column
  def defeated?
    defeated || current_hit_points <= 0
  end

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :encounter_id_min, -> { all }
  scope :encounter_id_max, -> { all }
  scope :encounter_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end