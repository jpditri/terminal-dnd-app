# frozen_string_literal: true

class TemplateRating < ApplicationRecord
  include Discard::Model

  belongs_to :campaign_template, optional: true
  belongs_to :user
  belongs_to :user

  validates :user_id, presence: true
  validates :rating, presence: true
  validates :helpful_count, numericality: true
  validate :must_have_template
  validate :one_rating_per_user_per_template
  validate :user_cannot_rate_own_template
  validates :user_id, presence: true

  scope :recent, -> { all }
  scope :for_template, -> { all }
  scope :high_rated, -> { all }
  scope :with_reviews, -> { all }
  scope :most_helpful, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end