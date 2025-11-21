# frozen_string_literal: true

class ContentRating < ApplicationRecord
  include Discard::Model

  belongs_to :shared_content
  belongs_to :user
  belongs_to :user

  validates :shared_content_id, presence: true
  validates :user_id, presence: true
  validates :rating, presence: true
  validates :helpful_count, numericality: true
  validate :one_rating_per_user_per_content
  validate :user_cannot_rate_own_content
  validates :user_id, presence: true

  scope :recent, -> { all }
  scope :for_content, -> { all }
  scope :high_rated, -> { all }
  scope :with_reviews, -> { all }
  scope :most_helpful, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end