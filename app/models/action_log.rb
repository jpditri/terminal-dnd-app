# frozen_string_literal: true

class ActionLog < ApplicationRecord
  belongs_to :user
  belongs_to :game_session
  belongs_to :user

  validates :action_type, presence: true
  validates :user_id, presence: true

  scope :recent, -> { all }
  scope :by_type, -> { all }
  scope :for_session, -> { all }
  scope :since, -> { all }
  scope :for_user, ->(user) { where(user: user) }

end