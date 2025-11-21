# frozen_string_literal: true

module Maps
  # Renders dungeon maps using tile sprites for classic RPG look
  # Generates data for canvas rendering on the client side
  class SpriteMapRenderer
    # Sprite sheet tile indices (assuming standard tileset layout)
    TILE_SPRITES = {
      'floor' => { row: 0, col: 0 },
      'floor_alt' => { row: 0, col: 1 },
      'wall' => { row: 1, col: 0 },
      'wall_top' => { row: 1, col: 1 },
      'wall_corner_tl' => { row: 1, col: 2 },
      'wall_corner_tr' => { row: 1, col: 3 },
      'wall_corner_bl' => { row: 1, col: 4 },
      'wall_corner_br' => { row: 1, col: 5 },
      'door' => { row: 2, col: 0 },
      'door_open' => { row: 2, col: 1 },
      'door_locked' => { row: 2, col: 2 },
      'door_secret' => { row: 2, col: 3 },
      'stairs_up' => { row: 3, col: 0 },
      'stairs_down' => { row: 3, col: 1 },
      'trap' => { row: 3, col: 2 },
      'trap_disabled' => { row: 3, col: 3 },
      'chest' => { row: 4, col: 0 },
      'chest_open' => { row: 4, col: 1 },
      'water' => { row: 4, col: 2 },
      'pit' => { row: 4, col: 3 },
      'pillar' => { row: 5, col: 0 },
      'altar' => { row: 5, col: 1 },
      'statue' => { row: 5, col: 2 },
      'empty' => { row: 0, col: 7 }
    }.freeze

    # Entity sprite indices
    ENTITY_SPRITES = {
      player: { row: 6, col: 0 },
      npc: { row: 6, col: 1 },
      enemy: { row: 6, col: 2 },
      boss: { row: 6, col: 3 }
    }.freeze

    attr_reader :dungeon_map, :tile_size, :sprite_size

    def initialize(dungeon_map, tile_size: 32, sprite_size: 16)
      @dungeon_map = dungeon_map
      @tile_size = tile_size
      @sprite_size = sprite_size  # Size of sprites in the tileset
    end

    # Generate render data for client-side canvas rendering
    def render_data(party_position = nil, fog_mode = nil)
      fog_mode ||= dungeon_map.fog_of_war_mode
      party_position ||= dungeon_map.party_position

      {
        width: dungeon_map.width,
        height: dungeon_map.height,
        tile_size: tile_size,
        sprite_size: sprite_size,
        tileset: tileset_info,
        tiles: generate_tile_data(fog_mode),
        entities: generate_entity_data(party_position, fog_mode),
        party: party_position ? {
          x: party_position.x,
          y: party_position.y,
          sprite: ENTITY_SPRITES[:player]
        } : nil,
        fog_mode: fog_mode
      }
    end

    # Generate optimized render list (only changed tiles)
    def render_diff(previous_state, party_position = nil, fog_mode = nil)
      current_data = render_data(party_position, fog_mode)

      # Compare and return only changed tiles
      changed_tiles = []

      current_data[:tiles].each do |tile|
        prev_tile = previous_state[:tiles]&.find { |t| t[:x] == tile[:x] && t[:y] == tile[:y] }

        if prev_tile.nil? || prev_tile != tile
          changed_tiles << tile
        end
      end

      current_data.merge(tiles: changed_tiles, is_diff: true)
    end

    private

    def tileset_info
      {
        url: '/assets/tilesets/dungeon.png',  # Path to tileset image
        tile_width: sprite_size,
        tile_height: sprite_size,
        columns: 8,
        rows: 8
      }
    end

    def generate_tile_data(fog_mode)
      tiles = []

      dungeon_map.tile_data.each do |tile|
        visibility = calculate_visibility(tile, fog_mode)
        next if visibility == :hidden

        sprite = get_sprite_for_tile(tile)

        tiles << {
          x: tile['x'],
          y: tile['y'],
          sprite: sprite,
          visibility: visibility,
          room_id: tile['room_id']
        }
      end

      tiles
    end

    def generate_entity_data(party_position, fog_mode)
      entities = []

      dungeon_map.map_rooms.each do |room|
        next unless room.visited? || fog_mode == 'none'

        # Enemies
        room.enemies.each do |enemy|
          next if enemy['defeated']

          entities << {
            type: enemy['is_boss'] ? :boss : :enemy,
            x: enemy['x'] || room.center[0],
            y: enemy['y'] || room.center[1],
            sprite: ENTITY_SPRITES[enemy['is_boss'] ? :boss : :enemy],
            id: enemy['id'],
            name: enemy['name']
          }
        end

        # NPCs
        room.npcs.each do |npc|
          next if npc.respond_to?(:dead?) && npc.dead?

          entities << {
            type: :npc,
            x: npc.try(:x) || room.center[0],
            y: npc.try(:y) || room.center[1],
            sprite: ENTITY_SPRITES[:npc],
            id: npc.id,
            name: npc.name
          }
        end
      end

      entities
    end

    def calculate_visibility(tile, fog_mode)
      case fog_mode
      when 'none'
        :visible
      when 'partial'
        if tile['visited']
          :visible
        elsif tile['revealed']
          :dim
        else
          :hidden
        end
      when 'full'
        tile['visited'] ? :visible : :hidden
      else
        :visible
      end
    end

    def get_sprite_for_tile(tile)
      tile_type = tile['type']

      # Check for wall auto-tiling
      if tile_type == 'wall'
        return auto_tile_wall(tile)
      end

      # Check for floor variation
      if tile_type == 'floor'
        return floor_variation(tile)
      end

      TILE_SPRITES[tile_type] || TILE_SPRITES['floor']
    end

    # Auto-tile walls based on neighbors
    def auto_tile_wall(tile)
      x = tile['x']
      y = tile['y']

      # Check neighbors
      north = wall_at?(x, y - 1)
      south = wall_at?(x, y + 1)
      east = wall_at?(x + 1, y)
      west = wall_at?(x - 1, y)

      # Determine wall type based on neighbors
      if !north && south && !east && !west
        TILE_SPRITES['wall_top']
      elsif north && !south && east && west
        TILE_SPRITES['wall']
      elsif !north && !south && !east && west
        TILE_SPRITES['wall_corner_tr']
      elsif !north && !south && east && !west
        TILE_SPRITES['wall_corner_tl']
      elsif north && !south && !east && west
        TILE_SPRITES['wall_corner_br']
      elsif north && !south && east && !west
        TILE_SPRITES['wall_corner_bl']
      else
        TILE_SPRITES['wall']
      end
    end

    def wall_at?(x, y)
      tile = dungeon_map.tile_at(x, y)
      tile && tile['type'] == 'wall'
    end

    # Add variation to floor tiles
    def floor_variation(tile)
      # Use position to deterministically vary floors
      if (tile['x'] + tile['y']) % 7 == 0
        TILE_SPRITES['floor_alt']
      else
        TILE_SPRITES['floor']
      end
    end
  end
end
