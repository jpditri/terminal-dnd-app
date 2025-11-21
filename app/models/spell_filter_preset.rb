# frozen_string_literal: true

class SpellFilterPreset < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :user

  validates :name, presence: true
  validates :filter_data, presence: true
  validate :validate_user_preset_limit
  validate :validate_filter_data_structure
  validate :validate_system_preset_requirements
  validates :user_id, presence: true

  scope :custom, -> { all }
  scope :system_presets, -> { all }
  scope :shared, -> { all }
  scope :public_presets, -> { all }
  scope :for_user, -> { all }
  scope :for_user, ->(user) { where(user: user) }

end