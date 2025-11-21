# frozen_string_literal: true

# WebSocket channel for AI DM interactions
# Handles real-time messaging, tool approvals, and state updates
class TerminalDmChannel < ApplicationCable::Channel
  def subscribed
    @session = TerminalSession.find_by(id: params[:session_id], user: current_user)

    if @session
      stream_for @session
      stream_from "terminal_session_#{@session.id}"

      # Send initial state
      transmit({
        type: 'connected',
        session_id: @session.id,
        mode: @session.mode,
        pending_approvals: pending_approvals
      })
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end

  # Player sends message to DM
  def send_message(data)
    message = data['message']

    # NEW: Command preprocessing layer
    preprocessor = Terminal::CommandPreprocessor.new(@session, message)

    # Handle instant response commands (inventory, stats, help)
    if preprocessor.instant_response?
      handle_instant_response(preprocessor.instant_result)
      return
    end

    # Check for soft blocks (warnings but allow)
    if preprocessor.soft_blocked?
      broadcast_warning(preprocessor.warning_message)
    end

    # Use AI DM orchestrator to process message
    orchestrator = AiDm::Orchestrator.new(@session)
    history = build_conversation_history
    response = orchestrator.process_message(preprocessor.expanded_message, history)

    # Save to conversation history
    @session.add_narrative(message, content_type: 'player')
    narrative_entry = @session.add_narrative(response[:narrative], content_type: 'dm')

    # Collect suggestions from all tool results and convert to quick actions
    all_suggestions = response[:tool_results]&.flat_map { |result| result[:suggestions] || [] } || []
    suggestion_actions = all_suggestions.map do |sug|
      {
        action_type: 'send_message',
        label: sug[:action],
        params: { message: sug[:examples]&.first || sug[:action] }
      }
    end

    # Combine with existing quick actions
    all_quick_actions = (response[:quick_actions] || []) + suggestion_actions

    # Broadcast AI response with rendered HTML
    broadcast_to @session, {
      type: 'dm_response',
      narrative: narrative_entry.rendered_content,
      is_html: true,
      tool_results: response[:tool_results] || [],
      pending_approvals: response[:pending_approvals] || [],
      quick_actions: all_quick_actions,
      state_updates: response[:state_updates] || [],
      timestamp: Time.current.iso8601
    }
  rescue StandardError => e
    Rails.logger.error "TerminalDmChannel error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    broadcast_to @session, {
      type: 'error',
      message: "Error processing message: #{e.message}",
      timestamp: Time.current.iso8601
    }
  end

  # Player approves pending action
  def approve_action(data)
    orchestrator = AiDm::Orchestrator.new(@session)
    result = orchestrator.handle_approval(
      data['action_id'],
      approved: true,
      reviewer: current_user
    )

    broadcast_to @session, {
      type: 'action_approved',
      action_id: data['action_id'],
      result: result[:result],
      follow_up: result[:follow_up],
      timestamp: Time.current.iso8601
    }

    # Update pending approvals list
    broadcast_pending_approvals
  end

  # Player rejects pending action
  def reject_action(data)
    orchestrator = AiDm::Orchestrator.new(@session)
    result = orchestrator.handle_approval(
      data['action_id'],
      approved: false,
      reason: data['reason'],
      reviewer: current_user
    )

    broadcast_to @session, {
      type: 'action_rejected',
      action_id: data['action_id'],
      follow_up: result[:follow_up],
      timestamp: Time.current.iso8601
    }

    # Update pending approvals list
    broadcast_pending_approvals
  end

  # Batch approve multiple actions
  def batch_approve(data)
    orchestrator = AiDm::Orchestrator.new(@session)
    result = orchestrator.batch_approve(data['action_ids'], reviewer: current_user)

    broadcast_to @session, {
      type: 'batch_approved',
      results: result[:results],
      all_success: result[:all_success],
      timestamp: Time.current.iso8601
    }

    broadcast_pending_approvals
  end

  # Player requests specific action (direct tool execution)
  def execute_action(data)
    executor = AiDm::ToolExecutor.new(@session, @session.character)
    result = executor.execute(
      data['tool'],
      (data['parameters'] || {}).deep_symbolize_keys,
      { trigger_source: 'player' }
    )

    broadcast_to @session, {
      type: 'action_result',
      tool: data['tool'],
      result: result,
      timestamp: Time.current.iso8601
    }
  end

  # Roll dice
  def roll_dice(data)
    executor = AiDm::ToolExecutor.new(@session, @session.character)
    result = executor.execute(
      :roll_dice,
      {
        dice_expression: data['dice'],
        purpose: data['purpose'] || 'Roll',
        dc: data['dc'],
        advantage: data['advantage'],
        disadvantage: data['disadvantage']
      }
    )

    broadcast_to @session, {
      type: 'dice_roll',
      result: result,
      timestamp: Time.current.iso8601
    }
  end

  # Change session mode
  def set_mode(data)
    @session.update!(mode: data['mode'])

    broadcast_to @session, {
      type: 'mode_changed',
      mode: data['mode'],
      timestamp: Time.current.iso8601
    }
  end

  # Get current game state
  def get_state(_data)
    transmit({
      type: 'game_state',
      character: character_state,
      combat: combat_state,
      pending_approvals: pending_approvals,
      mode: @session.mode,
      timestamp: Time.current.iso8601
    })
  end

  # Request quick action
  def quick_action(data)
    action_type = data['action']
    params = data['params'] || {}

    case action_type
    when 'search', 'look'
      send_message({ 'message' => 'I search the area carefully.' })
    when 'inventory'
      send_message({ 'message' => 'I check my inventory.' })
    when 'attack'
      send_message({ 'message' => "I attack #{params['target'] || 'the nearest enemy'}!" })
    when 'end_turn'
      execute_action({ 'tool' => 'next_turn', 'parameters' => {} })
    when 'talk'
      send_message({ 'message' => "I want to talk about #{params['topic'] || 'something'}." })
    when 'roll'
      roll_dice({ 'dice' => params['dice'] || '1d20', 'purpose' => params['purpose'] || 'Check' })
    when 'investigate'
      send_message({ 'message' => 'I investigate more closely.' })
    when 'persuade'
      send_message({ 'message' => 'I try to persuade them.' })
    when 'review_pending'
      transmit({
        type: 'pending_approvals',
        approvals: pending_approvals
      })
    else
      send_message({ 'message' => "I #{action_type.gsub('_', ' ')}." })
    end
  end

  private

  def handle_instant_response(result)
    # Broadcast instant response without LLM delay
    case result[:display_in]
    when 'side_panel'
      broadcast_to @session, {
        type: 'game_state',
        character: result[:character],
        timestamp: Time.current.iso8601
      }
    when 'narrative'
      broadcast_to @session, {
        type: 'instant_message',
        content: result[:content],
        title: result[:title],
        timestamp: Time.current.iso8601
      }
    end
  end

  def broadcast_warning(warning_message)
    broadcast_to @session, {
      type: 'warning',
      message: warning_message,
      timestamp: Time.current.iso8601
    }
  end

  def build_conversation_history
    @session.recent_narrative(10).map do |n|
      { role: n.content_type == 'player' ? 'user' : 'assistant', content: n.content }
    end
  end

  def pending_approvals
    DmPendingAction
      .where(terminal_session: @session)
      .pending
      .map do |action|
        {
          id: action.id,
          tool_name: action.tool_name,
          description: action.description,
          dm_reasoning: action.dm_reasoning,
          expires_at: action.expires_at&.iso8601,
          time_remaining: action.time_remaining&.to_i
        }
      end
  end

  def broadcast_pending_approvals
    broadcast_to @session, {
      type: 'pending_approvals_updated',
      approvals: pending_approvals
    }
  end

  def character_state
    char = @session.character
    return nil unless char

    {
      id: char.id,
      name: char.name,
      race: char.race&.name,
      class: char.character_class&.name,
      level: char.level,
      hp: char.hit_points_current,
      max_hp: char.hit_points_max,
      ac: char.calculated_armor_class,
      gold: char.gold,
      xp: char.experience,
      conditions: char.character_combat_tracker&.active_conditions || []
    }
  rescue StandardError
    nil
  end

  def combat_state
    return nil unless @session.character

    combat = Combat.where(status: 'active')
                   .joins(:combat_participants)
                   .where(combat_participants: { character_id: @session.character.id })
                   .first

    return nil unless combat

    manager = SoloPlay::CombatManager.new(combat)
    manager.get_combat_state
  rescue StandardError
    nil
  end
end
