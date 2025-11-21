# frozen_string_literal: true

module Maps
  # Handles party movement on dungeon maps
  class PartyMovementService
    attr_reader :dungeon_map, :party_position, :fog_service

    def initialize(dungeon_map, party_position = nil)
      @dungeon_map = dungeon_map
      @party_position = party_position || dungeon_map.party_position
      @fog_service = FogOfWarService.new(dungeon_map)
    end

    # Move to absolute position
    def move_to(target_x, target_y)
      # Validate target position
      return Result.failure(:out_of_bounds) unless valid_bounds?(target_x, target_y)
      return Result.failure(:blocked) if tile_blocked?(target_x, target_y)

      # Check if we need to pass through a locked door
      door_check = check_for_doors(party_position.x, party_position.y, target_x, target_y)
      return door_check if door_check.failure?

      # Check for traps along path
      trap_check = check_for_traps(party_position.x, party_position.y, target_x, target_y)

      # Move party
      old_room = dungeon_map.room_at(party_position.x, party_position.y)
      party_position.move_to(target_x, target_y)
      new_room = dungeon_map.room_at(target_x, target_y)

      # Update visibility
      fog_service.update_visibility(party_position)

      # Check for room transition
      room_entry_result = nil
      if new_room && new_room != old_room
        room_entry_result = trigger_room_entry(new_room)
      end

      Result.success(
        position: { x: target_x, y: target_y },
        old_room: old_room&.room_id,
        new_room: new_room&.room_id,
        room_entry: room_entry_result,
        trap_triggered: trap_check
      )
    end

    # Move in cardinal direction
    def move_direction(direction)
      delta = PartyPosition::DIRECTIONS[direction]
      return Result.failure(:invalid_direction) unless delta

      new_x = party_position.x + delta[0]
      new_y = party_position.y + delta[1]

      move_to(new_x, new_y)
    end

    # Get all valid moves from current position
    def get_valid_moves
      moves = []

      PartyPosition::DIRECTIONS.each do |direction, delta|
        new_x = party_position.x + delta[0]
        new_y = party_position.y + delta[1]

        next unless valid_bounds?(new_x, new_y)
        next if tile_blocked?(new_x, new_y)

        tile = dungeon_map.tile_at(new_x, new_y)
        room = dungeon_map.room_at(new_x, new_y)

        moves << {
          direction: direction,
          x: new_x,
          y: new_y,
          tile_type: tile&.dig('type'),
          room_id: room&.room_id,
          explored: tile&.dig('visited') || false
        }
      end

      moves
    end

    # Check if path exists between two points
    def path_exists?(from_x, from_y, to_x, to_y)
      # Simple BFS pathfinding
      return true if from_x == to_x && from_y == to_y

      visited = Set.new
      queue = [[from_x, from_y]]

      while queue.any?
        x, y = queue.shift
        key = "#{x},#{y}"

        next if visited.include?(key)

        visited.add(key)

        return true if x == to_x && y == to_y

        PartyPosition::DIRECTIONS.each_value do |delta|
          new_x = x + delta[0]
          new_y = y + delta[1]

          next unless valid_bounds?(new_x, new_y)
          next if tile_blocked?(new_x, new_y)
          next if visited.include?("#{new_x},#{new_y}")

          queue << [new_x, new_y]
        end
      end

      false
    end

    # Calculate shortest path
    def calculate_path(from_x, from_y, to_x, to_y)
      return [] if from_x == to_x && from_y == to_y

      visited = {}
      queue = [[from_x, from_y, []]]

      while queue.any?
        x, y, path = queue.shift
        key = "#{x},#{y}"

        next if visited[key]

        visited[key] = true
        current_path = path + [[x, y]]

        if x == to_x && y == to_y
          return current_path[1..]  # Exclude starting position
        end

        PartyPosition::DIRECTIONS.each do |direction, delta|
          new_x = x + delta[0]
          new_y = y + delta[1]

          next unless valid_bounds?(new_x, new_y)
          next if tile_blocked?(new_x, new_y)
          next if visited["#{new_x},#{new_y}"]

          queue << [new_x, new_y, current_path]
        end
      end

      []  # No path found
    end

    # Trigger room entry events
    def trigger_room_entry(room)
      # Mark room as visited
      room.visit!

      events = []

      # Check for enemies
      if room.enemies.any? && !room.cleared?
        events << {
          type: 'combat',
          enemies: room.enemies,
          message: "You've encountered enemies!"
        }
      end

      # Check for NPCs
      if room.npcs.any?
        events << {
          type: 'npc_encounter',
          npcs: room.npcs.map { |n| { id: n.id, name: n.name } },
          message: "You meet someone in this room."
        }
      end

      # Check for traps
      room.traps.each do |trap|
        next if trap['disarmed']

        events << {
          type: 'trap',
          trap: trap,
          message: "You sense danger..."
        }
      end

      # Check for treasure
      if room.items.any? && !room.looted?
        events << {
          type: 'treasure',
          items: room.items,
          message: "You spot something valuable."
        }
      end

      {
        room_id: room.room_id,
        room_type: room.room_type,
        description: room.description,
        events: events
      }
    end

    private

    def valid_bounds?(x, y)
      x >= 0 && y >= 0 && x < dungeon_map.width && y < dungeon_map.height
    end

    def tile_blocked?(x, y)
      tile = dungeon_map.tile_at(x, y)
      return true unless tile

      blocked_types = %w[wall pit empty]
      blocked_types.include?(tile['type'])
    end

    def check_for_doors(from_x, from_y, to_x, to_y)
      # Check each tile along path for doors
      path = calculate_path(from_x, from_y, to_x, to_y)

      path.each do |x, y|
        tile = dungeon_map.tile_at(x, y)
        next unless tile

        case tile['type']
        when 'door_locked'
          return Result.failure(
            :door_locked,
            message: "The door is locked. You need a key or lockpicking skill."
          )
        when 'door_secret'
          unless tile['discovered']
            return Result.failure(
              :secret_door,
              message: "You cannot pass through here."
            )
          end
        end
      end

      Result.success
    end

    def check_for_traps(from_x, from_y, to_x, to_y)
      path = calculate_path(from_x, from_y, to_x, to_y)
      triggered_traps = []

      path.each do |x, y|
        tile = dungeon_map.tile_at(x, y)
        next unless tile
        next unless tile['type'] == 'trap'
        next if tile['disarmed']

        # Roll perception to notice trap
        # (In real implementation, this would involve dice rolling)
        noticed = rand < 0.5

        if noticed
          triggered_traps << {
            x: x,
            y: y,
            noticed: true,
            message: "You notice a trap ahead!"
          }
        else
          triggered_traps << {
            x: x,
            y: y,
            triggered: true,
            message: "You triggered a trap!"
          }
        end
      end

      triggered_traps
    end
  end
end
