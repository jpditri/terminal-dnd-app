# frozen_string_literal: true

module Maps
  # Renders dungeon maps as ASCII art for terminal display
  class AsciiMapRenderer
    # Tile character mappings
    TILE_CHARS = {
      'floor' => '.',
      'wall' => '#',
      'door' => '+',
      'door_open' => '/',
      'door_locked' => 'X',
      'door_secret' => 'S',
      'stairs_up' => '<',
      'stairs_down' => '>',
      'trap' => '^',
      'trap_disabled' => 'v',
      'chest' => '$',
      'chest_open' => 'c',
      'water' => '~',
      'pit' => 'O',
      'pillar' => 'o',
      'altar' => 'T',
      'statue' => '&',
      'empty' => ' ',
      'unknown' => '?'
    }.freeze

    # Entity markers (override tiles)
    ENTITY_CHARS = {
      player: '@',
      npc: 'N',
      enemy: 'E',
      boss: 'B'
    }.freeze

    # Fog characters
    FOG_UNEXPLORED = ' '
    FOG_REVEALED = '?'

    attr_reader :dungeon_map

    def initialize(dungeon_map)
      @dungeon_map = dungeon_map
    end

    # Main render method
    def render(party_position = nil, fog_mode = nil)
      fog_mode ||= dungeon_map.fog_of_war_mode
      party_position ||= dungeon_map.party_position

      grid = create_grid
      apply_tiles(grid, fog_mode)
      apply_entities(grid, party_position, fog_mode)

      grid_to_string(grid)
    end

    # Render with legend
    def render_with_legend(party_position = nil, fog_mode = nil)
      map_output = render(party_position, fog_mode)
      legend = generate_legend

      "#{map_output}\n\n#{legend}"
    end

    # Render a specific room only
    def render_room(room, show_contents: true)
      width = room.width + 2  # +2 for borders
      height = room.height + 2
      grid = Array.new(height) { Array.new(width, ' ') }

      # Draw room walls
      (0...width).each do |x|
        grid[0][x] = '#'
        grid[height - 1][x] = '#'
      end
      (0...height).each do |y|
        grid[y][0] = '#'
        grid[y][width - 1] = '#'
      end

      # Fill floor
      (1...height - 1).each do |y|
        (1...width - 1).each do |x|
          grid[y][x] = '.'
        end
      end

      # Add connections (doors)
      room.connections.each do |conn|
        case conn['direction']
        when 'north'
          grid[0][width / 2] = door_char(conn['door_type'])
        when 'south'
          grid[height - 1][width / 2] = door_char(conn['door_type'])
        when 'east'
          grid[height / 2][width - 1] = door_char(conn['door_type'])
        when 'west'
          grid[height / 2][0] = door_char(conn['door_type'])
        end
      end

      # Add contents
      if show_contents
        add_room_contents(grid, room)
      end

      grid_to_string(grid)
    end

    # Generate mini-map for status display
    def render_minimap(center_x, center_y, radius: 5, fog_mode: nil)
      fog_mode ||= dungeon_map.fog_of_war_mode
      size = radius * 2 + 1
      grid = Array.new(size) { Array.new(size, ' ') }

      (0...size).each do |y|
        (0...size).each do |x|
          map_x = center_x - radius + x
          map_y = center_y - radius + y

          next if map_x < 0 || map_y < 0
          next if map_x >= dungeon_map.width || map_y >= dungeon_map.height

          tile = dungeon_map.tile_at(map_x, map_y)
          next unless tile

          char = tile_char(tile, fog_mode)

          # Party marker at center
          if x == radius && y == radius
            char = ENTITY_CHARS[:player]
          end

          grid[y][x] = char
        end
      end

      grid_to_string(grid)
    end

    private

    def create_grid
      Array.new(dungeon_map.height) { Array.new(dungeon_map.width, ' ') }
    end

    def apply_tiles(grid, fog_mode)
      dungeon_map.tile_data.each do |tile|
        x = tile['x']
        y = tile['y']
        next if x < 0 || y < 0 || x >= dungeon_map.width || y >= dungeon_map.height

        grid[y][x] = tile_char(tile, fog_mode)
      end
    end

    def tile_char(tile, fog_mode)
      case fog_mode
      when 'none'
        # Show everything
        TILE_CHARS[tile['type']] || '?'
      when 'partial'
        if tile['visited']
          TILE_CHARS[tile['type']] || '?'
        elsif tile['revealed']
          FOG_REVEALED
        else
          FOG_UNEXPLORED
        end
      when 'full'
        if tile['visited']
          TILE_CHARS[tile['type']] || '?'
        else
          FOG_UNEXPLORED
        end
      else
        TILE_CHARS[tile['type']] || '?'
      end
    end

    def apply_entities(grid, party_position, fog_mode)
      # Apply NPCs and enemies from rooms
      dungeon_map.map_rooms.each do |room|
        next unless room.visited? || fog_mode == 'none'

        # Enemies
        room.enemies.each do |enemy|
          x = enemy['x'] || room.center[0]
          y = enemy['y'] || room.center[1]
          next if x < 0 || y < 0 || x >= dungeon_map.width || y >= dungeon_map.height

          char = enemy['is_boss'] ? ENTITY_CHARS[:boss] : ENTITY_CHARS[:enemy]
          grid[y][x] = char unless enemy['defeated']
        end

        # NPCs
        room.npcs.each do |npc|
          next if npc.respond_to?(:dead?) && npc.dead?

          x = npc['x'] || npc.try(:x) || room.center[0]
          y = npc['y'] || npc.try(:y) || room.center[1]
          next if x < 0 || y < 0 || x >= dungeon_map.width || y >= dungeon_map.height

          grid[y][x] = ENTITY_CHARS[:npc]
        end
      end

      # Apply party position last (on top)
      if party_position
        x = party_position.x
        y = party_position.y
        grid[y][x] = ENTITY_CHARS[:player] if x >= 0 && y >= 0 && x < dungeon_map.width && y < dungeon_map.height
      end
    end

    def add_room_contents(grid, room)
      # Add enemies
      room.enemies.each_with_index do |enemy, i|
        # Place in room relative to center
        x = (grid[0].size / 2) + (i % 3) - 1
        y = (grid.size / 2) + (i / 3) - 1
        next if x <= 0 || y <= 0 || x >= grid[0].size - 1 || y >= grid.size - 1

        char = enemy['is_boss'] ? ENTITY_CHARS[:boss] : ENTITY_CHARS[:enemy]
        grid[y][x] = char unless enemy['defeated']
      end

      # Add items
      room.items.each_with_index do |item, i|
        x = (grid[0].size / 2) - (i % 2)
        y = grid.size - 2 - (i / 2)
        next if x <= 0 || y <= 0 || x >= grid[0].size - 1 || y >= grid.size - 1

        grid[y][x] = item['collected'] ? 'c' : '$'
      end
    end

    def door_char(door_type)
      case door_type
      when 'open', 'archway'
        '/'
      when 'locked'
        'X'
      when 'secret'
        'S'
      else
        '+'
      end
    end

    def grid_to_string(grid)
      grid.map(&:join).join("\n")
    end

    def generate_legend
      legend_items = [
        "Legend:",
        "  @ = You          # = Wall         . = Floor",
        "  + = Door         / = Open door    X = Locked",
        "  < = Stairs up    > = Stairs down  ^ = Trap",
        "  $ = Treasure     N = NPC          E = Enemy",
        "  B = Boss         ~ = Water        O = Pit"
      ]
      legend_items.join("\n")
    end
  end
end
