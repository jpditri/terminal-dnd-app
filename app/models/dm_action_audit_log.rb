# frozen_string_literal: true

class DmActionAuditLog < ApplicationRecord
  belongs_to :terminal_session
  belongs_to :character, optional: true
  belongs_to :dm_pending_action, optional: true

  validates :tool_name, presence: true
  validates :execution_status, inclusion: { in: %w[executed rolled_back failed] }

  scope :for_session, ->(session) { where(terminal_session: session) }
  scope :chronological, -> { order(created_at: :asc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :executed, -> { where(execution_status: 'executed') }
  scope :at_turn, ->(turn) { where(conversation_turn: turn) }

  # Reconstruct state at a given conversation turn
  def self.state_at_turn(session_id, turn)
    where(terminal_session_id: session_id)
      .where('conversation_turn <= ?', turn)
      .where(execution_status: 'executed')
      .order(:conversation_turn, :created_at)
      .reduce({}) do |state, log|
        state.deep_merge(log.state_after)
      end
  end

  # Get all actions that can be rewound (not already rolled back)
  def self.rewindable_actions(session_id, count = 1)
    where(terminal_session_id: session_id)
      .where(execution_status: 'executed')
      .order(created_at: :desc)
      .limit(count)
  end

  # Find the state to restore to for rewinding
  def self.rewind_target(session_id, turns_back)
    where(terminal_session_id: session_id)
      .where(execution_status: 'executed')
      .order(created_at: :desc)
      .offset(turns_back)
      .first
  end

  # Get summary of actions for a session
  def self.session_summary(session_id)
    where(terminal_session_id: session_id)
      .group(:tool_name)
      .count
  end

  # Human-readable action description
  def description
    "#{tool_name.humanize}: #{result['message'] || 'No message'}"
  end

  # Check if this action can be undone
  def rewindable?
    execution_status == 'executed' && state_before.present?
  end

  # Calculate the changes made by this action
  def changes
    return {} unless state_before.present? && state_after.present?

    diff = {}

    state_after.each do |key, after_value|
      before_value = state_before[key]
      if before_value != after_value
        diff[key] = {
          before: before_value,
          after: after_value
        }
      end
    end

    diff
  end

  # Get related actions in the same batch
  def batch_actions
    return [] unless dm_pending_action&.batch_id

    DmActionAuditLog.joins(:dm_pending_action)
                    .where(dm_pending_actions: { batch_id: dm_pending_action.batch_id })
                    .order('dm_pending_actions.batch_order')
  end
end
