# frozen_string_literal: true

# Main controller for terminal-style D&D interface
class TerminalController < ApplicationController
  before_action :authenticate_user!, if: -> { respond_to?(:authenticate_user!) }
  before_action :set_or_create_session

  layout 'terminal'

  # GET /terminal/new
  def new
    @session = create_new_session
    redirect_to terminal_path
  end

  # POST /terminal/create
  def create
    @session = create_new_session
    redirect_to terminal_path, notice: 'New adventure started!'
  end

  # GET /terminal
  def show
    @character = @session.character
    @dungeon_map = @session.dungeon_map
    @narrative_entries = @session.respond_to?(:recent_narrative) ? @session.recent_narrative(50) : []
    @quick_actions = @session.respond_to?(:current_actions) ? @session.current_actions : default_quick_actions

    # Render map if present
    if @dungeon_map
      @map_mode = @session.respond_to?(:map_render_mode) ? @session.map_render_mode : 'ascii'
      @show_map = @session.respond_to?(:show_map_panel) ? @session.show_map_panel : true

      if @map_mode == 'ascii'
        renderer = Maps::AsciiMapRenderer.new(@dungeon_map)
        party_pos = @session.respond_to?(:party_position) ? @session.party_position : nil
        @map_ascii = renderer.render(party_pos)
      end
    else
      @show_map = false
    end

    @page_title = @session.title || 'Adventure'
  end

  # POST /terminal/:id/input
  def process_input
    input = params[:input]&.strip
    return render json: { error: 'No input' }, status: :bad_request if input.blank?

    # Add to history
    @session.add_to_history(input)

    # Process through narrative service
    service = Terminal::TerminalNarrativeService.new(@session, @session.character)
    result = service.process_player_input(input, current_game_state)

    if result.success?
      render json: result.value
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  # GET /terminal/:id/quick_actions
  def quick_actions
    render json: @session.current_actions.map(&:as_json)
  end

  # POST /terminal/:id/toggle_map
  def toggle_map
    @session.update!(show_map_panel: !@session.show_map_panel)
    render json: { show_map: @session.show_map_panel }
  end

  # POST /terminal/:id/render_mode
  def change_render_mode
    mode = params[:mode]
    return render json: { error: 'Invalid mode' }, status: :bad_request unless %w[ascii svg sprite].include?(mode)

    @session.update!(map_render_mode: mode)
    render json: { mode: mode }
  end

  # GET /terminal/:id/export_history
  def export_history
    narrative = @session.narrative_outputs.order(:created_at).map do |entry|
      "[#{entry.created_at.strftime('%H:%M')}] #{entry.content}"
    end.join("\n\n")

    send_data narrative,
              filename: "#{@session.title || 'adventure'}_#{Time.current.strftime('%Y%m%d')}.txt",
              type: 'text/plain'
  end

  private

  def set_or_create_session
    # Try to find existing active session for the user
    if current_user
      @session = current_user.terminal_sessions.where(active: true).last
    end

    # Create new session if none found
    @session ||= TerminalSession.create!(
      user: current_user || guest_user,
      title: 'New Adventure',
      mode: 'creation',
      active: true
    )
  end

  def create_new_session
    # Deactivate any existing sessions
    current_user&.terminal_sessions&.update_all(active: false)

    TerminalSession.create!(
      user: current_user || guest_user,
      title: 'New Adventure',
      mode: 'creation',
      active: true
    )
  end

  def current_user
    @current_user ||= if defined?(super)
      super
    elsif session[:user_id]
      User.find_by(id: session[:user_id])
    end
  end

  def guest_user
    if cookies[:guest_user_id]
      User.find_by(id: cookies[:guest_user_id]) || create_guest_user
    else
      create_guest_user
    end
  end

  def create_guest_user
    guest_id = SecureRandom.hex(8)
    user = User.create!(
      email: "guest_#{guest_id}@terminal-dnd.local",
      username: "guest_#{guest_id}",
      password: SecureRandom.hex(16),
      guest: true
    )
    cookies[:guest_user_id] = { value: user.id, expires: 1.week.from_now }
    user
  rescue ActiveRecord::RecordInvalid
    # If creation fails, try to find existing guest
    User.find_by(id: cookies[:guest_user_id])
  end

  def current_game_state
    @session.solo_session&.current_game_state || {}
  end

  def default_quick_actions
    actions = []

    if @session&.character
      actions += [
        { label: 'Look around', action: 'search', icon: 'eye' },
        { label: 'Inventory', action: 'inventory', icon: 'backpack' }
      ]
    else
      actions += [
        { label: 'Create character', action: 'create', icon: 'plus' }
      ]
    end

    actions << { label: 'Help', action: 'help', icon: 'help' }
    actions
  end

  # View helper for HP status
  helper_method :hp_status_class
  def hp_status_class(character)
    return '' unless character

    percentage = (character.current_hp.to_f / character.max_hp) * 100

    if percentage <= 25
      'critical'
    elsif percentage <= 50
      'low'
    else
      ''
    end
  end

  # View helper for rendering narrative with clickables
  helper_method :render_narrative_content
  def render_narrative_content(entry)
    content = entry.content

    # Parse clickable elements
    if entry.clickable_elements.any?
      entry.clickable_elements.each do |clickable|
        pattern = /\[#{Regexp.escape(clickable['text'])}\]/
        replacement = %{<span class="clickable" data-type="#{clickable['type']}" data-target-id="#{clickable['id']}" data-action-type="#{clickable['action']}">#{clickable['text']}</span>}
        content = content.gsub(pattern, replacement)
      end
    end

    content.html_safe
  end
end
