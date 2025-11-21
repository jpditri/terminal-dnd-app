# frozen_string_literal: true

# Represents a suggested quick action in the terminal interface
class QuickAction < ApplicationRecord
  # Relationships
  belongs_to :terminal_session

  # Validations
  validates :label, presence: true
  validates :action_type, presence: true

  # Scopes
  scope :available, -> { where(is_available: true) }
  scope :ordered, -> { order(:sort_order) }

  # Action types
  ACTION_TYPES = %w[
    move
    investigate
    attack
    talk
    use
    cast
    rest
    search
    open
    take
    drop
    equip
    creation_choice
  ].freeze

  validates :action_type, inclusion: { in: ACTION_TYPES }

  # Check if action is on cooldown
  def on_cooldown?
    cooldown_until.present? && cooldown_until > Time.current
  end

  # Mark action as available
  def enable!
    update!(is_available: true)
  end

  # Mark action as unavailable
  def disable!
    update!(is_available: false)
  end

  # Set cooldown
  def set_cooldown(duration)
    update!(cooldown_until: Time.current + duration)
  end

  # Format for JSON response
  def as_json(options = {})
    {
      id: id,
      label: label,
      action_type: action_type,
      target_id: target_id,
      params: params,
      tooltip: tooltip,
      shortcut: keyboard_shortcut,
      requires_roll: requires_roll,
      skill_check: skill_check,
      dc: dc,
      available: is_available && !on_cooldown?
    }
  end
end
