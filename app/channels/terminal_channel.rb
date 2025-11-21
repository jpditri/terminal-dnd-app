# frozen_string_literal: true

# Main WebSocket channel for terminal D&D communication
class TerminalChannel < ApplicationCable::Channel
  def subscribed
    @session = TerminalSession.find(params[:session_id])
    @character = @session.character

    # Stream session updates
    stream_from "terminal_#{@session.id}"

    # Personal stream
    stream_from "terminal_#{@session.id}_user_#{current_user.id}"

    # Send initial state
    transmit(
      type: 'connected',
      session_id: @session.id,
      character: character_summary
    )
  end

  def unsubscribed
    stop_all_streams
  end

  # Process natural language input from user
  def process_input(data)
    input = data['input']

    # Use narrative service to process and generate response
    service = Terminal::TerminalNarrativeService.new(@session, @character)
    result = service.process_player_input(input, current_game_state)

    if result.success?
      broadcast_narrative(result.value)
    else
      transmit(type: 'error', message: result.error)
    end
  end

  # Execute a specific action (from quick actions or context menu)
  def execute_action(data)
    action_type = data['action_type']
    target_id = data['target_id']
    params = data['params'] || {}

    service = Terminal::TerminalNarrativeService.new(@session, @character)
    result = service.execute_action(action_type, target_id, params)

    if result.success?
      broadcast_narrative(result.value)
    else
      transmit(type: 'error', message: result.error)
    end
  end

  # Interact with narrative element
  def interact(data)
    element_type = data['element_type']
    target_id = data['target_id']
    action = data['action']

    case element_type
    when 'object'
      handle_object_interaction(target_id, action)
    when 'npc'
      handle_npc_interaction(target_id, action)
    when 'item'
      handle_item_interaction(target_id, action)
    when 'location'
      handle_location_interaction(target_id, action)
    else
      transmit(type: 'error', message: "Unknown element type: #{element_type}")
    end
  end

  # Roll dice
  def roll_dice(data)
    expression = data['expression']

    # Use dice roller service
    result = DiceRoller.new.parse_and_roll(expression)

    transmit(
      type: 'roll_result',
      expression: expression,
      total: result[:total],
      rolls: result[:results].flat_map { |r| r[:type] == :dice ? r[:rolls] : [] },
      modifier: result[:results].select { |r| r[:type] == :modifier }.sum { |r| r[:value] }
    )

    # Also broadcast as narrative
    broadcast_to_session(
      type: 'narrative',
      entry_type: 'roll',
      text: "#{@character&.name || 'You'} rolled #{expression}: #{result[:total]}"
    )
  end

  # Show inventory
  def show_inventory
    return transmit(type: 'error', message: 'No character loaded') unless @character

    items = @character.character_items.includes(:item).map do |ci|
      {
        name: ci.item&.name || ci.name,
        quantity: ci.quantity,
        equipped: ci.equipped,
        attuned: ci.attuned
      }
    end

    inventory_text = if items.any?
                       items.map { |i| "- #{i[:name]}#{i[:quantity] > 1 ? " (x#{i[:quantity]})" : ''}#{i[:equipped] ? ' [E]' : ''}" }.join("\n")
                     else
                       'Your inventory is empty.'
                     end

    transmit(
      type: 'narrative',
      entry_type: 'system',
      text: "Inventory:\n#{inventory_text}"
    )
  end

  # Show character sheet
  def show_character
    return transmit(type: 'error', message: 'No character loaded') unless @character

    sheet = <<~SHEET
      #{@character.name} - Level #{@character.level} #{@character.character_class&.name}
      #{@character.race&.name} | #{@character.alignment&.name}

      HP: #{@character.current_hp}/#{@character.max_hp} | AC: #{@character.armor_class}

      STR: #{@character.strength} (#{modifier_string(@character.strength)})
      DEX: #{@character.dexterity} (#{modifier_string(@character.dexterity)})
      CON: #{@character.constitution} (#{modifier_string(@character.constitution)})
      INT: #{@character.intelligence} (#{modifier_string(@character.intelligence)})
      WIS: #{@character.wisdom} (#{modifier_string(@character.wisdom)})
      CHA: #{@character.charisma} (#{modifier_string(@character.charisma)})

      Proficiency Bonus: +#{@character.proficiency_bonus}
    SHEET

    transmit(
      type: 'narrative',
      entry_type: 'system',
      text: sheet
    )
  end

  # Take a rest
  def rest(data)
    rest_type = data['type'] || 'short'

    return transmit(type: 'error', message: 'No character loaded') unless @character

    case rest_type
    when 'short'
      # Spend hit dice
      transmit(
        type: 'narrative',
        entry_type: 'system',
        text: "You take a short rest (1 hour). You may spend hit dice to recover HP."
      )
    when 'long'
      # Full recovery
      @character.update!(current_hp: @character.max_hp)
      transmit(
        type: 'narrative',
        entry_type: 'system',
        text: "You take a long rest (8 hours). HP fully restored."
      )
      transmit(
        type: 'character_update',
        character: character_summary
      )
    end
  end

  # Generate a new map
  def generate_map(data)
    template = data['template'] || 'small_dungeon'

    # Create dungeon map
    dungeon_map = DungeonMap.create!(
      solo_session: @session.solo_session,
      name: "#{template.humanize} - #{Time.current.strftime('%Y%m%d')}",
      width: 50,
      height: 50
    )

    # Generate structure
    service = Maps::MapTemplateService.new(dungeon_map)
    service.generate_structure(template)

    # Create party position at entrance
    entrance = dungeon_map.map_rooms.find_by(room_type: 'entrance')
    if entrance
      PartyPosition.create!(
        dungeon_map: dungeon_map,
        x: entrance.center_x,
        y: entrance.center_y,
        current_room: entrance
      )
    end

    # Update session
    @session.update!(dungeon_map: dungeon_map)

    transmit(
      type: 'map_generated',
      map_id: dungeon_map.id,
      name: dungeon_map.name
    )
  end

  # Start character creation
  def start_character_creation
    service = Terminal::CharacterCreationConversationService.new(@session)
    result = service.start_creation

    transmit(
      type: 'narrative',
      entry_type: 'dm',
      text: result.value[:message],
      quick_actions: result.value[:options]&.map do |opt|
        { label: opt[:label], action_type: 'creation_choice', params: { step: result.value[:step], choice: opt[:value] } }
      end
    )
  end

  # Load a character
  def load_character(data)
    name = data['name']

    character = if name.present?
                  current_user.characters.find_by('LOWER(name) = ?', name.downcase)
                else
                  current_user.characters.last
                end

    if character
      @character = character
      @session.update!(character: character)

      transmit(
        type: 'narrative',
        entry_type: 'system',
        text: "Character loaded: #{character.name}"
      )
      transmit(
        type: 'character_update',
        character: character_summary
      )
    else
      transmit(
        type: 'error',
        message: name.present? ? "Character '#{name}' not found." : 'No characters found.'
      )
    end
  end

  # Save game
  def save_game
    @session.update!(updated_at: Time.current)

    transmit(
      type: 'system',
      message: 'Game saved.'
    )
  end

  # Quit game
  def quit_game
    save_game
    @session.update!(is_active: false)

    transmit(
      type: 'system',
      message: 'Game ended. Thanks for playing!'
    )
  end

  private

  def current_game_state
    @session.solo_session&.current_game_state || SoloGameState.new
  end

  def character_summary
    return nil unless @character

    {
      id: @character.id,
      name: @character.name,
      level: @character.level,
      class_name: @character.character_class&.name,
      race_name: @character.race&.name,
      current_hp: @character.current_hp,
      max_hp: @character.max_hp,
      armor_class: @character.armor_class
    }
  end

  def modifier_string(score)
    mod = (score - 10) / 2
    mod >= 0 ? "+#{mod}" : mod.to_s
  end

  def broadcast_narrative(narrative_data)
    broadcast_to_session(
      type: 'narrative',
      entry_type: narrative_data[:entry_type] || 'dm',
      text: narrative_data[:text],
      clickables: narrative_data[:clickables],
      quick_actions: narrative_data[:quick_actions]
    )
  end

  def broadcast_to_session(data)
    ActionCable.server.broadcast("terminal_#{@session.id}", data)
  end

  def handle_object_interaction(target_id, action)
    # Generate narrative response for object interaction
    service = Terminal::TerminalNarrativeService.new(@session, @character)
    result = service.interact_with_object(target_id, action)

    if result.success?
      broadcast_narrative(result.value)
    else
      transmit(type: 'error', message: result.error)
    end
  end

  def handle_npc_interaction(target_id, action)
    npc = Npc.find_by(id: target_id)
    return transmit(type: 'error', message: 'NPC not found') unless npc

    case action
    when 'talk'
      # Start dialogue
      service = Terminal::TerminalNarrativeService.new(@session, @character)
      result = service.start_dialogue(npc)
      broadcast_narrative(result.value) if result.success?
    when 'examine'
      transmit(
        type: 'narrative',
        entry_type: 'dm',
        text: "#{npc.name}: #{npc.description || 'You see a ' + npc.race&.name.to_s + '.'}"
      )
    when 'attack'
      # Initiate combat
      service = Terminal::TerminalNarrativeService.new(@session, @character)
      result = service.initiate_combat([npc])
      broadcast_narrative(result.value) if result.success?
    end
  end

  def handle_item_interaction(target_id, action)
    service = Terminal::TerminalNarrativeService.new(@session, @character)
    result = service.interact_with_item(target_id, action)

    if result.success?
      broadcast_narrative(result.value)
    else
      transmit(type: 'error', message: result.error)
    end
  end

  def handle_location_interaction(target_id, action)
    service = Terminal::TerminalNarrativeService.new(@session, @character)
    result = service.travel_to_location(target_id)

    if result.success?
      broadcast_narrative(result.value)
    else
      transmit(type: 'error', message: result.error)
    end
  end
end
