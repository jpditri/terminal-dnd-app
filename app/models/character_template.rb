# frozen_string_literal: true

class CharacterTemplate < ApplicationRecord
  belongs_to :user
  belongs_to :user

  validates :name, presence: true
  validates :template_type, presence: true
  validates :min_level, numericality: true
  validates :max_level, numericality: true
  validate :max_level_greater_than_min_level
  validates :user_id, presence: true

  scope :public_templates, -> { all }
  scope :private_templates, -> { all }
  scope :by_user, -> { all }
  scope :by_type, -> { all }
  scope :by_class, -> { all }
  scope :for_user, ->(user) { where(user: user) }

end