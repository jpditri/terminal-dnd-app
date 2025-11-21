# frozen_string_literal: true

class UserThemePreference < ApplicationRecord
  belongs_to :user
  belongs_to :user
  validates :user_id, presence: true

  scope :dark_mode, -> { all }
  scope :high_contrast, -> { all }
  scope :for_user, ->(user) { where(user: user) }

end