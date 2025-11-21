# frozen_string_literal: true

module Maps
  # Renders dungeon maps as SVG for scalable graphical display
  class SvgMapRenderer
    # Tile colors
    TILE_COLORS = {
      'floor' => '#8B7355',
      'wall' => '#4a4a4a',
      'door' => '#8B4513',
      'door_open' => '#D2691E',
      'door_locked' => '#4a0000',
      'door_secret' => '#4a4a4a',
      'stairs_up' => '#666666',
      'stairs_down' => '#666666',
      'trap' => '#ff4444',
      'trap_disabled' => '#884444',
      'chest' => '#FFD700',
      'chest_open' => '#B8860B',
      'water' => '#4169E1',
      'pit' => '#1a1a1a',
      'pillar' => '#808080',
      'altar' => '#9932CC',
      'statue' => '#A9A9A9',
      'empty' => '#000000'
    }.freeze

    # Entity colors
    ENTITY_COLORS = {
      player: '#00ff00',
      npc: '#00aaff',
      enemy: '#ff0000',
      boss: '#ff00ff'
    }.freeze

    attr_reader :dungeon_map, :tile_size

    def initialize(dungeon_map, tile_size: 16)
      @dungeon_map = dungeon_map
      @tile_size = tile_size
    end

    # Render full map as SVG string
    def render(party_position = nil, fog_mode = nil)
      fog_mode ||= dungeon_map.fog_of_war_mode
      party_position ||= dungeon_map.party_position

      width = dungeon_map.width * tile_size
      height = dungeon_map.height * tile_size

      svg = build_svg_header(width, height)
      svg << build_styles
      svg << build_background(width, height)
      svg << build_tiles(fog_mode)
      svg << build_entities(party_position, fog_mode)
      svg << build_party_marker(party_position) if party_position
      svg << "</svg>"

      svg
    end

    # Render to data URL for embedding
    def render_data_url(party_position = nil, fog_mode = nil)
      svg = render(party_position, fog_mode)
      encoded = Base64.strict_encode64(svg)
      "data:image/svg+xml;base64,#{encoded}"
    end

    # Render single tile as SVG element
    def tile_to_svg(tile, x_offset = 0, y_offset = 0)
      x = tile['x'] * tile_size + x_offset
      y = tile['y'] * tile_size + y_offset
      tile_type = tile['type']

      case tile_type
      when 'wall'
        wall_tile(x, y)
      when 'door', 'door_closed'
        door_tile(x, y, :closed)
      when 'door_open'
        door_tile(x, y, :open)
      when 'door_locked'
        door_tile(x, y, :locked)
      when 'stairs_up'
        stairs_tile(x, y, :up)
      when 'stairs_down'
        stairs_tile(x, y, :down)
      when 'trap'
        trap_tile(x, y, false)
      when 'trap_disabled'
        trap_tile(x, y, true)
      when 'chest'
        chest_tile(x, y, false)
      when 'chest_open'
        chest_tile(x, y, true)
      when 'water'
        water_tile(x, y)
      when 'pit'
        pit_tile(x, y)
      when 'pillar'
        pillar_tile(x, y)
      when 'altar'
        altar_tile(x, y)
      when 'statue'
        statue_tile(x, y)
      else
        floor_tile(x, y)
      end
    end

    private

    def build_svg_header(width, height)
      <<~SVG
        <?xml version="1.0" encoding="UTF-8"?>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="#{width}"
             height="#{height}"
             viewBox="0 0 #{width} #{height}">
      SVG
    end

    def build_styles
      <<~SVG
        <defs>
          <pattern id="grid" width="#{tile_size}" height="#{tile_size}" patternUnits="userSpaceOnUse">
            <path d="M #{tile_size} 0 L 0 0 0 #{tile_size}" fill="none" stroke="#333" stroke-width="0.5"/>
          </pattern>
          <filter id="fog">
            <feColorMatrix type="matrix" values="0.3 0 0 0 0 0 0.3 0 0 0 0 0 0.3 0 0 0 0 0 1 0"/>
          </filter>
          <filter id="glow">
            <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
            <feMerge>
              <feMergeNode in="coloredBlur"/>
              <feMergeNode in="SourceGraphic"/>
            </feMerge>
          </filter>
        </defs>
      SVG
    end

    def build_background(width, height)
      %{<rect width="#{width}" height="#{height}" fill="#000"/>}
    end

    def build_tiles(fog_mode)
      tiles_svg = "<g id=\"tiles\">\n"

      dungeon_map.tile_data.each do |tile|
        visible = case fog_mode
                  when 'none'
                    true
                  when 'partial'
                    tile['revealed'] || tile['visited']
                  when 'full'
                    tile['visited']
                  else
                    true
                  end

        next unless visible

        tiles_svg << tile_to_svg(tile)

        # Add fog overlay for revealed but not visited
        if fog_mode == 'partial' && tile['revealed'] && !tile['visited']
          x = tile['x'] * tile_size
          y = tile['y'] * tile_size
          tiles_svg << %{<rect x="#{x}" y="#{y}" width="#{tile_size}" height="#{tile_size}" fill="#000" opacity="0.5"/>\n}
        end
      end

      tiles_svg << "</g>\n"
      tiles_svg
    end

    def build_entities(party_position, fog_mode)
      entities_svg = "<g id=\"entities\">\n"

      dungeon_map.map_rooms.each do |room|
        next unless room.visited? || fog_mode == 'none'

        # Enemies
        room.enemies.each do |enemy|
          next if enemy['defeated']

          x = (enemy['x'] || room.center[0]) * tile_size + tile_size / 2
          y = (enemy['y'] || room.center[1]) * tile_size + tile_size / 2
          color = enemy['is_boss'] ? ENTITY_COLORS[:boss] : ENTITY_COLORS[:enemy]

          entities_svg << entity_marker(x, y, color, enemy['is_boss'] ? 'B' : 'E')
        end

        # NPCs
        room.npcs.each do |npc|
          next if npc.respond_to?(:dead?) && npc.dead?

          x = (npc.try(:x) || room.center[0]) * tile_size + tile_size / 2
          y = (npc.try(:y) || room.center[1]) * tile_size + tile_size / 2

          entities_svg << entity_marker(x, y, ENTITY_COLORS[:npc], 'N')
        end
      end

      entities_svg << "</g>\n"
      entities_svg
    end

    def build_party_marker(party_position)
      x = party_position.x * tile_size + tile_size / 2
      y = party_position.y * tile_size + tile_size / 2
      radius = tile_size / 3

      <<~SVG
        <g id="party" filter="url(#glow)">
          <circle cx="#{x}" cy="#{y}" r="#{radius}" fill="#{ENTITY_COLORS[:player]}" stroke="#fff" stroke-width="1"/>
          <text x="#{x}" y="#{y + 3}" text-anchor="middle" fill="#000" font-size="#{tile_size / 2}" font-weight="bold">@</text>
        </g>
      SVG
    end

    # Tile rendering methods
    def floor_tile(x, y)
      color = TILE_COLORS['floor']
      <<~SVG
        <rect x="#{x}" y="#{y}" width="#{tile_size}" height="#{tile_size}" fill="#{color}"/>
      SVG
    end

    def wall_tile(x, y)
      color = TILE_COLORS['wall']
      <<~SVG
        <rect x="#{x}" y="#{y}" width="#{tile_size}" height="#{tile_size}" fill="#{color}" stroke="#333" stroke-width="1"/>
      SVG
    end

    def door_tile(x, y, state)
      color = case state
              when :open then TILE_COLORS['door_open']
              when :locked then TILE_COLORS['door_locked']
              else TILE_COLORS['door']
              end

      svg = %{<rect x="#{x}" y="#{y}" width="#{tile_size}" height="#{tile_size}" fill="#{TILE_COLORS['floor']}"/>}

      # Door rectangle
      door_width = tile_size * 0.6
      door_height = tile_size * 0.8
      door_x = x + (tile_size - door_width) / 2
      door_y = y + (tile_size - door_height) / 2

      svg << %{<rect x="#{door_x}" y="#{door_y}" width="#{door_width}" height="#{door_height}" fill="#{color}" rx="2"/>}

      # Lock indicator
      if state == :locked
        svg << %{<circle cx="#{x + tile_size * 0.7}" cy="#{y + tile_size / 2}" r="2" fill="#FFD700"/>}
      end

      svg
    end

    def stairs_tile(x, y, direction)
      svg = floor_tile(x, y)

      # Draw steps
      step_count = 3
      step_height = tile_size / (step_count + 1)

      step_count.times do |i|
        step_y = direction == :up ? y + tile_size - (i + 1) * step_height : y + i * step_height
        step_width = tile_size * (0.5 + i * 0.15)
        step_x = x + (tile_size - step_width) / 2

        svg << %{<rect x="#{step_x}" y="#{step_y}" width="#{step_width}" height="#{step_height - 1}" fill="#666"/>}
      end

      # Direction arrow
      arrow_y = direction == :up ? y + 3 : y + tile_size - 6
      svg << %{<text x="#{x + tile_size / 2}" y="#{arrow_y + 3}" text-anchor="middle" fill="#fff" font-size="6">#{direction == :up ? '↑' : '↓'}</text>}

      svg
    end

    def trap_tile(x, y, disabled)
      svg = floor_tile(x, y)
      color = disabled ? TILE_COLORS['trap_disabled'] : TILE_COLORS['trap']

      # Trap spikes
      cx = x + tile_size / 2
      cy = y + tile_size / 2

      svg << %{<polygon points="#{cx},#{y + 3} #{x + 3},#{y + tile_size - 3} #{x + tile_size - 3},#{y + tile_size - 3}" fill="#{color}"/>}

      svg
    end

    def chest_tile(x, y, opened)
      svg = floor_tile(x, y)
      color = opened ? TILE_COLORS['chest_open'] : TILE_COLORS['chest']

      # Chest body
      chest_width = tile_size * 0.7
      chest_height = tile_size * 0.5
      chest_x = x + (tile_size - chest_width) / 2
      chest_y = y + tile_size - chest_height - 2

      svg << %{<rect x="#{chest_x}" y="#{chest_y}" width="#{chest_width}" height="#{chest_height}" fill="#{color}" rx="2"/>}

      # Chest lid (if closed)
      unless opened
        lid_height = tile_size * 0.2
        svg << %{<rect x="#{chest_x}" y="#{chest_y - lid_height}" width="#{chest_width}" height="#{lid_height}" fill="#{color}" rx="2"/>}
      end

      svg
    end

    def water_tile(x, y)
      <<~SVG
        <rect x="#{x}" y="#{y}" width="#{tile_size}" height="#{tile_size}" fill="#{TILE_COLORS['water']}"/>
        <path d="M #{x + 2} #{y + tile_size / 2} Q #{x + tile_size / 4} #{y + tile_size / 3} #{x + tile_size / 2} #{y + tile_size / 2} T #{x + tile_size - 2} #{y + tile_size / 2}" fill="none" stroke="#6495ED" stroke-width="1"/>
      SVG
    end

    def pit_tile(x, y)
      <<~SVG
        <rect x="#{x}" y="#{y}" width="#{tile_size}" height="#{tile_size}" fill="#{TILE_COLORS['pit']}"/>
        <ellipse cx="#{x + tile_size / 2}" cy="#{y + tile_size / 2}" rx="#{tile_size / 3}" ry="#{tile_size / 4}" fill="#333"/>
      SVG
    end

    def pillar_tile(x, y)
      svg = floor_tile(x, y)
      cx = x + tile_size / 2
      cy = y + tile_size / 2
      radius = tile_size / 4

      svg << %{<circle cx="#{cx}" cy="#{cy}" r="#{radius}" fill="#{TILE_COLORS['pillar']}" stroke="#666" stroke-width="1"/>}
      svg
    end

    def altar_tile(x, y)
      svg = floor_tile(x, y)

      altar_width = tile_size * 0.8
      altar_height = tile_size * 0.4
      altar_x = x + (tile_size - altar_width) / 2
      altar_y = y + tile_size - altar_height - 2

      svg << %{<rect x="#{altar_x}" y="#{altar_y}" width="#{altar_width}" height="#{altar_height}" fill="#{TILE_COLORS['altar']}" rx="1"/>}
      svg
    end

    def statue_tile(x, y)
      svg = floor_tile(x, y)
      cx = x + tile_size / 2
      cy = y + tile_size / 2

      # Simple humanoid shape
      svg << %{<circle cx="#{cx}" cy="#{y + tile_size / 4}" r="#{tile_size / 6}" fill="#{TILE_COLORS['statue']}"/>}
      svg << %{<rect x="#{cx - tile_size / 6}" y="#{y + tile_size / 3}" width="#{tile_size / 3}" height="#{tile_size / 2}" fill="#{TILE_COLORS['statue']}"/>}
      svg
    end

    def entity_marker(x, y, color, label)
      <<~SVG
        <circle cx="#{x}" cy="#{y}" r="#{tile_size / 3}" fill="#{color}" stroke="#fff" stroke-width="1"/>
        <text x="#{x}" y="#{y + 3}" text-anchor="middle" fill="#fff" font-size="#{tile_size / 2}" font-weight="bold">#{label}</text>
      SVG
    end
  end
end
