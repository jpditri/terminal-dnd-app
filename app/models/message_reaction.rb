# frozen_string_literal: true

class MessageReaction < ApplicationRecord
  belongs_to :chat_message
  belongs_to :user
  belongs_to :user

  validates :emoji, presence: true
  validates :user_id, uniqueness: true
  validates :user_id, presence: true

  scope :for_user, ->(user) { where(user: user) }

end