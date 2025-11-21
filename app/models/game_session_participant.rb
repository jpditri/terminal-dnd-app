# frozen_string_literal: true

class GameSessionParticipant < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :game_session
  belongs_to :user
  belongs_to :character, optional: true
  belongs_to :user
  validates :user_id, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :pending_invitations, -> { all }
  scope :accepted, -> { all }
  scope :declined, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end