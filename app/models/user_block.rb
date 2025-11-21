# frozen_string_literal: true

class UserBlock < ApplicationRecord
  include Discard::Model

  belongs_to :blocker
  belongs_to :blocked

  validates :blocker_id, presence: true
  validates :blocked_id, presence: true
  validate :cannot_block_yourself
  validate :no_duplicate_blocks

  scope :for_blocker, -> { all }
  scope :for_blocked, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end