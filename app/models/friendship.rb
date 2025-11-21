# frozen_string_literal: true

class Friendship < ApplicationRecord
  include Discard::Model

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, presence: true
  validates :friend_id, presence: true
  validates :status, presence: true
  validate :cannot_friend_yourself
  validate :friendship_must_be_unique

  scope :active, -> { where(status: 'accepted') }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

  private

  def cannot_friend_yourself
    errors.add(:friend_id, "can't be yourself") if user_id == friend_id
  end

  def friendship_must_be_unique
    if Friendship.where(user_id: user_id, friend_id: friend_id).where.not(id: id).exists?
      errors.add(:base, 'Friendship already exists')
    end
  end
end
