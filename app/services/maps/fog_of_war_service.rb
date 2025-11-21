# frozen_string_literal: true

module Maps
  # Manages fog of war visibility on dungeon maps
  class FogOfWarService
    attr_reader :dungeon_map

    def initialize(dungeon_map)
      @dungeon_map = dungeon_map
    end

    # Update visibility based on party position and mode
    def update_visibility(party_position, mode = nil)
      mode ||= dungeon_map.fog_of_war_mode

      case mode
      when 'full'
        reveal_visited_only(party_position)
      when 'partial'
        reveal_current_and_adjacent(party_position)
      when 'none'
        reveal_all
      end

      dungeon_map.save!
    end

    # Change fog of war mode
    def set_mode(mode)
      return Result.failure(:invalid_mode) unless %w[full partial none].include?(mode)

      dungeon_map.update!(fog_of_war_mode: mode)

      # Re-apply visibility with new mode
      if dungeon_map.party_position
        update_visibility(dungeon_map.party_position, mode)
      end

      Result.success(mode: mode)
    end

    # Reveal a specific room (DM action)
    def reveal_room(room)
      room.tiles.each do |tile|
        tile['revealed'] = true
      end
      dungeon_map.save!
      Result.success(room_id: room.room_id)
    end

    # Hide a previously revealed room (DM action)
    def hide_room(room)
      room.tiles.each do |tile|
        tile['revealed'] = false unless tile['visited']
      end
      dungeon_map.save!
      Result.success(room_id: room.room_id)
    end

    # Reveal specific tile
    def reveal_tile(x, y)
      tile = dungeon_map.tile_at(x, y)
      return Result.failure(:tile_not_found) unless tile

      tile['revealed'] = true
      dungeon_map.save!
      Result.success(x: x, y: y)
    end

    # Get visibility status for a position
    def visible?(x, y)
      tile = dungeon_map.tile_at(x, y)
      return false unless tile

      case dungeon_map.fog_of_war_mode
      when 'none'
        true
      when 'partial'
        tile['revealed'] || tile['visited']
      when 'full'
        tile['visited']
      else
        false
      end
    end

    # Get all visible tiles
    def visible_tiles
      case dungeon_map.fog_of_war_mode
      when 'none'
        dungeon_map.tile_data
      when 'partial'
        dungeon_map.tile_data.select { |t| t['revealed'] || t['visited'] }
      when 'full'
        dungeon_map.tile_data.select { |t| t['visited'] }
      else
        []
      end
    end

    # Calculate line of sight from position
    def line_of_sight(from_x, from_y, radius: 5)
      visible = []

      (-radius..radius).each do |dy|
        (-radius..radius).each do |dx|
          x = from_x + dx
          y = from_y + dy

          next if x < 0 || y < 0 || x >= dungeon_map.width || y >= dungeon_map.height

          # Check if line of sight is blocked
          if has_line_of_sight?(from_x, from_y, x, y)
            visible << [x, y]
          end
        end
      end

      visible
    end

    private

    def reveal_visited_only(party_position)
      return unless party_position

      room = dungeon_map.room_at(party_position.x, party_position.y)
      return unless room

      # Mark current room as visited
      room.visit!

      # Reveal only visited tiles
      room.tiles.each do |tile|
        tile['visited'] = true
        tile['revealed'] = true
      end
    end

    def reveal_current_and_adjacent(party_position)
      return unless party_position

      current_room = dungeon_map.room_at(party_position.x, party_position.y)
      return unless current_room

      # Mark and reveal current room
      current_room.visit!
      current_room.tiles.each do |tile|
        tile['visited'] = true
        tile['revealed'] = true
      end

      # Reveal connections to adjacent rooms
      current_room.connections.each do |conn|
        target_room = dungeon_map.map_rooms.find_by(room_id: conn['target_room_id'])
        next unless target_room

        # Reveal the door and corridor, but not the full room
        reveal_connection_path(current_room, target_room, conn['direction'])

        # Mark adjacent room edges as revealed but not visited
        target_room.tiles.each do |tile|
          tile['revealed'] = true unless tile['visited']
        end
      end
    end

    def reveal_all
      dungeon_map.tile_data.each do |tile|
        tile['revealed'] = true
      end
    end

    def reveal_connection_path(from_room, to_room, direction)
      # Reveal tiles between rooms (corridor)
      case direction
      when 'north'
        y_start = to_room.bounds['y2']
        y_end = from_room.bounds['y1']
        x = from_room.center_x

        (y_start..y_end).each do |y|
          tile = dungeon_map.tile_at(x, y)
          tile['revealed'] = true if tile
        end
      when 'south'
        y_start = from_room.bounds['y2']
        y_end = to_room.bounds['y1']
        x = from_room.center_x

        (y_start..y_end).each do |y|
          tile = dungeon_map.tile_at(x, y)
          tile['revealed'] = true if tile
        end
      when 'east'
        x_start = from_room.bounds['x2']
        x_end = to_room.bounds['x1']
        y = from_room.center_y

        (x_start..x_end).each do |x|
          tile = dungeon_map.tile_at(x, y)
          tile['revealed'] = true if tile
        end
      when 'west'
        x_start = to_room.bounds['x2']
        x_end = from_room.bounds['x1']
        y = from_room.center_y

        (x_start..x_end).each do |x|
          tile = dungeon_map.tile_at(x, y)
          tile['revealed'] = true if tile
        end
      end
    end

    def has_line_of_sight?(x1, y1, x2, y2)
      # Bresenham's line algorithm to check for walls
      dx = (x2 - x1).abs
      dy = (y2 - y1).abs
      sx = x1 < x2 ? 1 : -1
      sy = y1 < y2 ? 1 : -1
      err = dx - dy

      x = x1
      y = y1

      while x != x2 || y != y2
        tile = dungeon_map.tile_at(x, y)
        return false if tile && tile['type'] == 'wall'

        e2 = 2 * err
        if e2 > -dy
          err -= dy
          x += sx
        end
        if e2 < dx
          err += dx
          y += sy
        end
      end

      true
    end
  end
end
