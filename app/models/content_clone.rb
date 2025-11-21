# frozen_string_literal: true

class ContentClone < ApplicationRecord
  include Discard::Model

  belongs_to :shared_content
  belongs_to :user
  belongs_to :cloned_content, polymorphic: true
  belongs_to :user

  validates :shared_content_id, presence: true
  validates :user_id, presence: true
  validates :cloned_content_type, presence: true
  validates :cloned_content_id, presence: true
  validates :user_id, presence: true

  scope :recent, -> { all }
  scope :for_user, -> { all }
  scope :for_shared_content, -> { all }
  scope :by_content_type, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end