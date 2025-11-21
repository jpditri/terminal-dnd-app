# frozen_string_literal: true

class Combatant < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :combat_encounter
  belongs_to :character, optional: true
  has_many :active_effects, dependent: :destroy
  has_many :damage_logs_as_source
  has_many :damage_logs_as_target
  has_many :healing_logs_as_source
  has_many :healing_logs_as_target

  scope :pcs, -> { all }
  scope :npcs, -> { all }
  scope :conscious, -> { all }
  scope :unconscious, -> { all }
  scope :stable, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end