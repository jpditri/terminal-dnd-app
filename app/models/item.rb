# frozen_string_literal: true

# Item model for D&D 5e items and equipment
# Ported from heretical-web-app with adaptations for terminal-dnd
#
# Key Features:
# - Magic item tracking
# - Attunement requirements
# - Weight and cost management
# - Rarity filtering (Common, Uncommon, Rare, Very Rare, Legendary, Artifact)
# - JSONB properties for flexible item data
class Item < ApplicationRecord
  include Discard::Model

  has_paper_trail

  # Validations
  validates :name, presence: true

  # Scopes
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

  scope :recent, -> { order(created_at: :desc) }
  scope :search_name, ->(query) { where("name LIKE ?", "%#{query}%") if query.present? }
  scope :filter_rarity, ->(value) { where(rarity: value) if value.present? }
  scope :search_description, ->(query) { where("description LIKE ?", "%#{query}%") if query.present? }
  scope :weight_min, ->(value) { where("weight >= ?", value) if value.present? }
  scope :weight_max, ->(value) { where("weight <= ?", value) if value.present? }
  scope :weight_range, ->(min, max) { where(weight: min..max) if min.present? && max.present? }
  scope :cost_gp_min, ->(value) { where("cost_gp >= ?", value) if value.present? }
  scope :cost_gp_max, ->(value) { where("cost_gp <= ?", value) if value.present? }
  scope :cost_gp_range, ->(min, max) { where(cost_gp: min..max) if min.present? && max.present? }
  scope :magic_filter, ->(value) { where(magic: value) unless value.nil? }
  scope :requires_attunement_filter, ->(value) { where(requires_attunement: value) unless value.nil? }
  scope :search_all, lambda { |query|
    where("name LIKE :query OR description LIKE :query", query: "%#{query}%") if query.present?
  }

  # Display helper
  def display_name
    respond_to?(:name) ? name : "Item ##{id}"
  end
end