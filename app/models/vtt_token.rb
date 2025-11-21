# frozen_string_literal: true

class VttToken < ApplicationRecord
  belongs_to :vtt_session
  belongs_to :character, optional: true
  belongs_to :npc, optional: true
  belongs_to :monster, optional: true
  validates :rotation, numericality: true
  validates :x, numericality: true
  validate :has_one_entity

  scope :visible, -> { all }
  scope :hidden_tokens, -> { all }
  scope :player_tokens, -> { all }
  scope :npc_tokens, -> { all }
  scope :defeated, -> { all }

end