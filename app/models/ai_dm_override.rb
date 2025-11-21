# frozen_string_literal: true

class AiDmOverride < ApplicationRecord
  belongs_to :ai_dm_assistant
  belongs_to :ai_dm_suggestion
  belongs_to :user
  belongs_to :user

  validates :original_suggestion, presence: true
  validates :dm_override, presence: true
  validates :override_type, presence: true
  validates :user_id, presence: true

  scope :recent, -> { all }
  scope :by_type, -> { all }
  scope :for_user, ->(user) { where(user: user) }

end