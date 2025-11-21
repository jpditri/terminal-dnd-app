# frozen_string_literal: true

class Session < ApplicationRecord
  belongs_to :user
  belongs_to :user

  validates :user_id, presence: true

  scope :for_user, ->(user) { where(user: user) }

end