# frozen_string_literal: true

class DiceRoll < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :user
  belongs_to :character, optional: true
  belongs_to :game_session, optional: true
  belongs_to :combat, optional: true
  belongs_to :combat_action, optional: true
  belongs_to :dm_approver, optional: true
  belongs_to :original_roll, optional: true
  belongs_to :superseded_by_roll, optional: true
  has_many :rerolls, dependent: :nullify
  belongs_to :user

  validates :roll_type, presence: true
  validates :total, presence: true, numericality: true
  validates :results, presence: true
  validates :state, presence: true
  validates :user_id, presence: true

  scope :active, -> { all }
  scope :visible, -> { all }
  scope :hidden_rolls, -> { all }
  scope :by_roll_type, -> { all }
  scope :recent, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end