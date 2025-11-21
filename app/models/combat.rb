# frozen_string_literal: true

class Combat < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :encounter, optional: true
  belongs_to :game_session, optional: true
  has_many :solo_sessions, dependent: :nullify
  has_many :combat_participants, dependent: :destroy
  has_many :combat_actions, dependent: :destroy
  has_many :dice_rolls, dependent: :destroy

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :encounter_id_min, -> { all }
  scope :encounter_id_max, -> { all }
  scope :encounter_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end