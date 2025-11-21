# frozen_string_literal: true

class DmPendingAction < ApplicationRecord
  include Discard::Model
  has_paper_trail

  belongs_to :terminal_session
  belongs_to :character, optional: true
  belongs_to :user

  has_one :audit_log, class_name: 'DmActionAuditLog', dependent: :destroy

  validates :tool_name, presence: true
  validates :status, inclusion: { in: %w[pending approved rejected expired executed failed] }

  scope :pending, -> { where(status: 'pending') }
  scope :batch, ->(batch_id) { where(batch_id: batch_id).order(:batch_order) }
  scope :expired, -> { where(status: 'pending').where('expires_at < ?', Time.current) }
  scope :recent, -> { order(created_at: :desc) }

  # Default expiration of 5 minutes for time-sensitive actions
  before_create :set_default_expiration

  # Approve and execute the pending action
  def approve!(reviewer:)
    transaction do
      update!(
        status: 'approved',
        reviewed_at: Time.current,
        reviewed_by: reviewer.id
      )

      # Execute the action
      executor = AiDm::ToolExecutor.new(terminal_session, character)
      result = executor.execute(tool_name, parameters.deep_symbolize_keys, skip_approval: true)

      update!(
        status: result[:success] ? 'executed' : 'failed',
        execution_result: result,
        error_message: result[:error]
      )

      # Create audit log
      create_audit_log!(
        terminal_session: terminal_session,
        character: character,
        tool_name: tool_name,
        parameters: parameters,
        result: result,
        execution_status: result[:success] ? 'executed' : 'failed',
        trigger_source: 'player_approval'
      )

      result
    end
  end

  # Reject the pending action
  def reject!(reason: nil)
    update!(
      status: 'rejected',
      reviewed_at: Time.current,
      player_response: reason
    )

    # Notify AI for conversation continuity
    broadcast_rejection(reason)
  end

  # Get tool configuration
  def tool_config
    AiDm::ToolRegistry.get(tool_name)
  end

  # Check if this tool requires approval
  def requires_approval?
    tool_config&.dig(:approval_required) || false
  end

  # Human-readable description of the action
  def description
    case tool_name
    when 'set_ability_score'
      "Set #{parameters['ability']} to #{parameters['value']}"
    when 'grant_skill_proficiency'
      "Grant #{parameters['expertise'] ? 'expertise' : 'proficiency'} in #{parameters['skill']}"
    when 'level_up'
      'Level up character'
    when 'modify_backstory'
      parameters['append'] ? 'Append to backstory' : 'Update backstory'
    when 'rewind_turn'
      "Rewind #{parameters['turns_back']} turn(s)"
    else
      tool_name.humanize
    end
  end

  # Time remaining before expiration
  def time_remaining
    return nil unless expires_at

    remaining = expires_at - Time.current
    remaining.positive? ? remaining : 0
  end

  # Check if expired
  def expired?
    expires_at && Time.current > expires_at
  end

  private

  def set_default_expiration
    self.expires_at ||= 5.minutes.from_now
  end

  def broadcast_rejection(reason)
    ActionCable.server.broadcast(
      "terminal_session_#{terminal_session_id}",
      {
        type: 'action_rejected',
        action_id: id,
        tool_name: tool_name,
        reason: reason
      }
    )
  end
end
