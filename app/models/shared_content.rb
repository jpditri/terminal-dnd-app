# frozen_string_literal: true

class SharedContent < ApplicationRecord
  include Discard::Model

  belongs_to :user
  belongs_to :content, polymorphic: true
  has_many :content_clones, dependent: :destroy
  has_many :content_ratings, dependent: :destroy
  belongs_to :user

  validates :user_id, presence: true
  validates :content_type, presence: true
  validates :content_id, presence: true
  validates :title, presence: true
  validates :visibility, presence: true
  validates :license_type, presence: true
  validates :view_count, numericality: true
  validates :clone_count, numericality: true
  validate :user_owns_content
  validates :user_id, presence: true

  scope :public_content, -> { all }
  scope :unlisted_content, -> { all }
  scope :private_content, -> { all }
  scope :by_content_type, -> { all }
  scope :by_license, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end