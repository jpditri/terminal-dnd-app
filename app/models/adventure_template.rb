# frozen_string_literal: true

class AdventureTemplate < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :author
  has_many :template_ratings, dependent: :destroy
  has_many :solo_sessions, dependent: :nullify

  validates :creator_id, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :difficulty, presence: true
  validates :status, presence: true
  validates :min_level, presence: true, numericality: true
  validates :max_level, presence: true, numericality: true
  validates :estimated_duration, presence: true, numericality: true
  validates :usage_count, numericality: true
  validates :template_data, presence: true
  validate :max_level_greater_than_min_level
  validate :validate_template_data_structure

  scope :published, -> { all }
  scope :draft, -> { all }
  scope :recent, -> { all }
  scope :popular, -> { all }
  scope :public_templates, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end