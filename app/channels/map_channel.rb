# frozen_string_literal: true

# WebSocket channel for real-time map updates
class MapChannel < ApplicationCable::Channel
  def subscribed
    @dungeon_map = DungeonMap.find(params[:map_id])

    # Stream map updates
    stream_from "map_#{@dungeon_map.id}"

    # Personal stream for user-specific notifications
    stream_from "map_#{@dungeon_map.id}_user_#{current_user.id}"

    # Send initial map state
    transmit(
      type: 'initial_state',
      map: map_state,
      party_position: party_position_state
    )
  end

  def unsubscribed
    stop_all_streams
  end

  # Move party to position
  def move(data)
    x = data['x'].to_i
    y = data['y'].to_i

    party_position = @dungeon_map.party_position
    return transmit(error: 'No party position') unless party_position

    service = Maps::PartyMovementService.new(@dungeon_map, party_position)
    result = service.move_to(x, y)

    if result.success?
      broadcast_map_update
      broadcast_movement(result.value)

      # Broadcast room entry if applicable
      if result.value[:room_entry]
        broadcast_room_entry(result.value[:room_entry])
      end
    else
      transmit(error: result.error, message: result.errors.first)
    end
  end

  # Move in direction
  def move_direction(data)
    direction = data['direction']

    party_position = @dungeon_map.party_position
    return transmit(error: 'No party position') unless party_position

    service = Maps::PartyMovementService.new(@dungeon_map, party_position)
    result = service.move_direction(direction)

    if result.success?
      broadcast_map_update
      broadcast_movement(result.value)

      if result.value[:room_entry]
        broadcast_room_entry(result.value[:room_entry])
      end
    else
      transmit(error: result.error)
    end
  end

  # Change fog of war mode (DM only)
  def set_fog_mode(data)
    mode = data['mode']

    # TODO: Add authorization check for DM
    service = Maps::FogOfWarService.new(@dungeon_map)
    result = service.set_mode(mode)

    if result.success?
      broadcast_map_update
      broadcast_fog_change(mode)
    else
      transmit(error: result.error)
    end
  end

  # Reveal specific room (DM only)
  def reveal_room(data)
    room_id = data['room_id'].to_i
    room = @dungeon_map.map_rooms.find_by(room_id: room_id)
    return transmit(error: 'Room not found') unless room

    service = Maps::FogOfWarService.new(@dungeon_map)
    result = service.reveal_room(room)

    if result.success?
      broadcast_map_update
    else
      transmit(error: result.error)
    end
  end

  # Hide specific room (DM only)
  def hide_room(data)
    room_id = data['room_id'].to_i
    room = @dungeon_map.map_rooms.find_by(room_id: room_id)
    return transmit(error: 'Room not found') unless room

    service = Maps::FogOfWarService.new(@dungeon_map)
    result = service.hide_room(room)

    if result.success?
      broadcast_map_update
    else
      transmit(error: result.error)
    end
  end

  # Change render mode (personal preference)
  def set_render_mode(data)
    mode = data['mode']
    return transmit(error: 'Invalid mode') unless %w[ascii svg sprite].include?(mode)

    # Store preference (would typically be in user settings)
    transmit(type: 'render_mode_changed', mode: mode)
  end

  # Request map export
  def export_map(data)
    format = data['format'] || 'ascii'
    options = data['options'] || {}

    service = Maps::MapExportService.new(@dungeon_map)
    result = service.create_export(format, current_user, options.symbolize_keys)

    if result.success?
      transmit(
        type: 'export_ready',
        filename: result.value[:filename],
        download_url: service.generate_download_url(result.value[:export])
      )
    else
      transmit(error: result.error)
    end
  end

  # Interact with room element
  def interact(data)
    room_id = data['room_id'].to_i
    element_type = data['element_type']
    element_id = data['element_id']

    room = @dungeon_map.map_rooms.find_by(room_id: room_id)
    return transmit(error: 'Room not found') unless room

    # Handle different interaction types
    case element_type
    when 'door'
      handle_door_interaction(room, element_id, data)
    when 'chest'
      handle_chest_interaction(room, element_id)
    when 'trap'
      handle_trap_interaction(room, element_id)
    else
      transmit(error: 'Unknown element type')
    end
  end

  private

  def map_state
    {
      id: @dungeon_map.id,
      name: @dungeon_map.name,
      width: @dungeon_map.width,
      height: @dungeon_map.height,
      fog_of_war_mode: @dungeon_map.fog_of_war_mode,
      tiles: visible_tiles,
      rooms: visible_rooms
    }
  end

  def party_position_state
    pos = @dungeon_map.party_position
    return nil unless pos

    {
      x: pos.x,
      y: pos.y,
      facing: pos.facing,
      current_room_id: pos.current_room&.room_id
    }
  end

  def visible_tiles
    service = Maps::FogOfWarService.new(@dungeon_map)
    service.visible_tiles
  end

  def visible_rooms
    @dungeon_map.map_rooms.select do |room|
      room.visited? || @dungeon_map.fog_of_war_mode == 'none'
    end.map do |room|
      {
        room_id: room.room_id,
        room_type: room.room_type,
        bounds: room.bounds,
        visited: room.visited,
        cleared: room.cleared
      }
    end
  end

  def broadcast_map_update
    @dungeon_map.reload

    ActionCable.server.broadcast(
      "map_#{@dungeon_map.id}",
      type: 'map_update',
      tiles: visible_tiles,
      rooms: visible_rooms,
      fog_mode: @dungeon_map.fog_of_war_mode
    )
  end

  def broadcast_movement(movement_data)
    ActionCable.server.broadcast(
      "map_#{@dungeon_map.id}",
      type: 'movement',
      position: movement_data[:position],
      old_room: movement_data[:old_room],
      new_room: movement_data[:new_room]
    )
  end

  def broadcast_room_entry(entry_data)
    ActionCable.server.broadcast(
      "map_#{@dungeon_map.id}",
      type: 'room_entry',
      room_id: entry_data[:room_id],
      room_type: entry_data[:room_type],
      description: entry_data[:description],
      events: entry_data[:events]
    )
  end

  def broadcast_fog_change(mode)
    ActionCable.server.broadcast(
      "map_#{@dungeon_map.id}",
      type: 'fog_mode_changed',
      mode: mode
    )
  end

  def handle_door_interaction(room, door_id, data)
    connection = room.connections.find { |c| c['id'] == door_id }
    return transmit(error: 'Door not found') unless connection

    action = data['action'] || 'open'

    case action
    when 'open'
      if connection['door_type'] == 'locked'
        transmit(type: 'interaction_result', result: 'locked', message: 'The door is locked.')
      else
        connection['door_type'] = 'open'
        room.save!
        broadcast_map_update
        transmit(type: 'interaction_result', result: 'success', message: 'You open the door.')
      end
    when 'pick_lock'
      # Would involve dice roll
      transmit(type: 'skill_check_required', skill: 'sleight_of_hand', dc: 15)
    when 'force'
      # Would involve strength check
      transmit(type: 'skill_check_required', skill: 'athletics', dc: 18)
    end
  end

  def handle_chest_interaction(room, chest_id)
    item = room.items.find { |i| i['id'] == chest_id }
    return transmit(error: 'Chest not found') unless item

    if item['collected']
      transmit(type: 'interaction_result', result: 'empty', message: 'The chest is empty.')
    else
      item['collected'] = true
      room.save!
      broadcast_map_update
      transmit(
        type: 'loot_collected',
        item: item,
        message: "You found: #{item['name']}"
      )
    end
  end

  def handle_trap_interaction(room, trap_id)
    trap = room.traps.find { |t| t['id'] == trap_id }
    return transmit(error: 'Trap not found') unless trap

    if trap['disarmed']
      transmit(type: 'interaction_result', result: 'already_disarmed', message: 'This trap has been disarmed.')
    else
      # Would involve thieves' tools check
      transmit(type: 'skill_check_required', skill: 'sleight_of_hand', dc: trap['dc'] || 15, tool: 'thieves_tools')
    end
  end
end
