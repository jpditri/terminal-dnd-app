# frozen_string_literal: true

class CampaignTemplate < ApplicationRecord
  include Discard::Model

  belongs_to :user
  has_many :template_ratings, dependent: :destroy
  has_many :campaigns, dependent: :nullify
  belongs_to :user

  validates :user_id, presence: true
  validates :name, presence: true
  validates :visibility, presence: true
  validates :template_data, presence: true
  validates :use_count, numericality: true
  validates :user_id, presence: true

  scope :public_templates, -> { all }
  scope :unlisted_templates, -> { all }
  scope :private_templates, -> { all }
  scope :by_category, -> { all }
  scope :by_level_range, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end