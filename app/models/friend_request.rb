# frozen_string_literal: true

class FriendRequest < ApplicationRecord
  include Discard::Model

  belongs_to :sender
  belongs_to :receiver

  validates :sender_id, presence: true
  validates :receiver_id, presence: true
  validates :status, presence: true
  validate :cannot_request_yourself
  validate :no_duplicate_pending_requests
  validate :cannot_request_if_already_friends
  validate :cannot_request_if_blocked

  scope :pending, -> { all }
  scope :accepted, -> { all }
  scope :declined, -> { all }
  scope :for_user, -> { all }
  scope :sent_by, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end