# frozen_string_literal: true

class SessionPresence < ApplicationRecord
  belongs_to :user
  belongs_to :game_session
  belongs_to :user
  validates :connection_count, numericality: true
  validates :user_id, presence: true

  scope :online, -> { all }
  scope :offline, -> { all }
  scope :away, -> { all }
  scope :active, -> { all }
  scope :recent, -> { all }
  scope :for_user, ->(user) { where(user: user) }

end