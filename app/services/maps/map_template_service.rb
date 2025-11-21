# frozen_string_literal: true

module Maps
  # Generates dungeon structure from templates
  # Templates provide room count and layout rules
  # AI populates content after generation
  class MapTemplateService
    # Predefined template configurations
    TEMPLATES = {
      small_dungeon: {
        room_count: 5..8,
        has_boss: true,
        trap_density: :low,
        treasure_density: :medium,
        layout: :branching,
        room_types: %w[entrance chamber corridor treasure boss]
      },
      medium_dungeon: {
        room_count: 10..15,
        has_boss: true,
        trap_density: :medium,
        treasure_density: :medium,
        layout: :branching,
        room_types: %w[entrance chamber corridor hallway intersection treasure trap boss]
      },
      large_dungeon: {
        room_count: 20..30,
        has_boss: true,
        trap_density: :high,
        treasure_density: :high,
        layout: :complex,
        room_types: %w[entrance chamber corridor hallway intersection shrine library armory treasure trap boss]
      },
      cave_system: {
        room_count: 8..12,
        has_boss: true,
        trap_density: :low,
        treasure_density: :low,
        layout: :organic,
        room_types: %w[entrance natural_cave corridor pool treasure boss]
      },
      castle_floor: {
        room_count: 12..18,
        has_boss: true,
        trap_density: :medium,
        treasure_density: :high,
        layout: :symmetrical,
        room_types: %w[entrance hallway chamber throne bedroom kitchen armory library prison treasure boss]
      },
      crypt: {
        room_count: 8..12,
        has_boss: true,
        trap_density: :high,
        treasure_density: :medium,
        layout: :linear,
        room_types: %w[entrance corridor crypt shrine altar treasure trap boss]
      },
      tower: {
        room_count: 5..8,
        has_boss: true,
        trap_density: :medium,
        treasure_density: :medium,
        layout: :vertical,
        room_types: %w[entrance stairs chamber laboratory library treasure boss]
      }
    }.freeze

    attr_reader :dungeon_map

    def initialize(dungeon_map)
      @dungeon_map = dungeon_map
    end

    # Generate complete dungeon structure
    def generate_structure(template_type, difficulty: :medium, options: {})
      template = TEMPLATES[template_type.to_sym] || TEMPLATES[:small_dungeon]

      # Determine room count
      room_count = options[:room_count] || rand(template[:room_count])

      # Generate rooms
      rooms = generate_rooms(room_count, template, difficulty)

      # Connect rooms based on layout style
      connect_rooms(rooms, template[:layout])

      # Place doors
      place_doors(rooms, template)

      # Convert to tile data and save
      convert_to_tiles(rooms)

      # Save metadata
      dungeon_map.update!(
        template_type: template_type.to_s,
        template_data: template.merge(difficulty: difficulty),
        metadata: {
          room_count: rooms.size,
          generated_at: Time.current,
          difficulty: difficulty
        }
      )

      rooms
    end

    private

    def generate_rooms(count, template, difficulty)
      rooms = []

      # Always start with entrance
      rooms << create_room(0, 'entrance', determine_room_size('entrance', difficulty))

      # Generate middle rooms
      remaining_types = template[:room_types] - %w[entrance boss]
      (1...count - 1).each do |i|
        room_type = remaining_types.sample
        rooms << create_room(i, room_type, determine_room_size(room_type, difficulty))
      end

      # Add boss room at end if specified
      if template[:has_boss]
        rooms << create_room(count - 1, 'boss', determine_room_size('boss', difficulty))
      else
        room_type = remaining_types.sample
        rooms << create_room(count - 1, room_type, determine_room_size(room_type, difficulty))
      end

      # Position rooms on map
      position_rooms(rooms, template[:layout])

      rooms
    end

    def create_room(id, type, size)
      MapRoom.new(
        dungeon_map: dungeon_map,
        room_id: id,
        room_type: type,
        bounds: { 'x1' => 0, 'y1' => 0, 'x2' => size[:width] - 1, 'y2' => size[:height] - 1 },
        connections: [],
        contents: {},
        visited: false
      )
    end

    def determine_room_size(room_type, difficulty)
      base_sizes = {
        'entrance' => { width: 5, height: 5 },
        'corridor' => { width: 3, height: 8 },
        'hallway' => { width: 4, height: 10 },
        'chamber' => { width: 7, height: 7 },
        'boss' => { width: 10, height: 10 },
        'throne' => { width: 9, height: 9 },
        'library' => { width: 8, height: 6 },
        'armory' => { width: 6, height: 6 },
        'treasure' => { width: 5, height: 5 },
        'trap' => { width: 5, height: 5 },
        'shrine' => { width: 6, height: 6 },
        'natural_cave' => { width: 8, height: 8 },
        'pool' => { width: 7, height: 7 }
      }

      base = base_sizes[room_type] || { width: 6, height: 6 }

      # Adjust for difficulty
      modifier = case difficulty
                 when :easy then 0.8
                 when :hard then 1.2
                 else 1.0
                 end

      {
        width: [(base[:width] * modifier).to_i, 3].max,
        height: [(base[:height] * modifier).to_i, 3].max
      }
    end

    def position_rooms(rooms, layout_style)
      case layout_style
      when :linear
        position_linear(rooms)
      when :branching
        position_branching(rooms)
      when :organic
        position_organic(rooms)
      when :symmetrical
        position_symmetrical(rooms)
      when :vertical
        position_vertical(rooms)
      else
        position_branching(rooms)
      end
    end

    def position_linear(rooms)
      x_offset = 2
      y_center = dungeon_map.height / 2

      rooms.each do |room|
        room_width = room.bounds['x2'] - room.bounds['x1'] + 1
        room_height = room.bounds['y2'] - room.bounds['y1'] + 1

        room.bounds = {
          'x1' => x_offset,
          'y1' => y_center - room_height / 2,
          'x2' => x_offset + room_width - 1,
          'y2' => y_center - room_height / 2 + room_height - 1
        }
        room.center_x = x_offset + room_width / 2
        room.center_y = y_center

        x_offset += room_width + 3  # Gap between rooms
      end
    end

    def position_branching(rooms)
      return if rooms.empty?

      placed = [rooms.first]
      pending = rooms[1..]

      # Place entrance at center-left
      first_room = rooms.first
      first_width = first_room.bounds['x2'] - first_room.bounds['x1'] + 1
      first_height = first_room.bounds['y2'] - first_room.bounds['y1'] + 1
      first_room.bounds = {
        'x1' => 5,
        'y1' => dungeon_map.height / 2 - first_height / 2,
        'x2' => 5 + first_width - 1,
        'y2' => dungeon_map.height / 2 - first_height / 2 + first_height - 1
      }
      first_room.center_x = 5 + first_width / 2
      first_room.center_y = dungeon_map.height / 2

      # Place remaining rooms
      directions = ['east', 'north', 'south']
      pending.each_with_index do |room, i|
        parent = placed.sample
        direction = directions[i % directions.size]

        place_adjacent(room, parent, direction)
        placed << room
      end
    end

    def position_organic(rooms)
      # Similar to branching but with more randomness
      position_branching(rooms)

      # Add some random offset to positions
      rooms.each do |room|
        offset_x = rand(-2..2)
        offset_y = rand(-2..2)

        room.bounds['x1'] += offset_x
        room.bounds['x2'] += offset_x
        room.bounds['y1'] += offset_y
        room.bounds['y2'] += offset_y
        room.center_x += offset_x
        room.center_y += offset_y
      end
    end

    def position_symmetrical(rooms)
      # Place rooms in a grid pattern
      cols = Math.sqrt(rooms.size).ceil
      cell_width = dungeon_map.width / (cols + 1)
      cell_height = dungeon_map.height / (cols + 1)

      rooms.each_with_index do |room, i|
        col = i % cols
        row = i / cols

        room_width = room.bounds['x2'] - room.bounds['x1'] + 1
        room_height = room.bounds['y2'] - room.bounds['y1'] + 1

        center_x = (col + 1) * cell_width
        center_y = (row + 1) * cell_height

        room.bounds = {
          'x1' => center_x - room_width / 2,
          'y1' => center_y - room_height / 2,
          'x2' => center_x + room_width / 2,
          'y2' => center_y + room_height / 2
        }
        room.center_x = center_x
        room.center_y = center_y
      end
    end

    def position_vertical(rooms)
      y_offset = 2
      x_center = dungeon_map.width / 2

      rooms.each do |room|
        room_width = room.bounds['x2'] - room.bounds['x1'] + 1
        room_height = room.bounds['y2'] - room.bounds['y1'] + 1

        room.bounds = {
          'x1' => x_center - room_width / 2,
          'y1' => y_offset,
          'x2' => x_center + room_width / 2,
          'y2' => y_offset + room_height - 1
        }
        room.center_x = x_center
        room.center_y = y_offset + room_height / 2

        y_offset += room_height + 3
      end
    end

    def place_adjacent(room, parent, direction)
      room_width = room.bounds['x2'] - room.bounds['x1'] + 1
      room_height = room.bounds['y2'] - room.bounds['y1'] + 1
      gap = 4  # Corridor length

      case direction
      when 'north'
        new_y = parent.bounds['y1'] - room_height - gap
        new_x = parent.center_x - room_width / 2
      when 'south'
        new_y = parent.bounds['y2'] + gap + 1
        new_x = parent.center_x - room_width / 2
      when 'east'
        new_x = parent.bounds['x2'] + gap + 1
        new_y = parent.center_y - room_height / 2
      when 'west'
        new_x = parent.bounds['x1'] - room_width - gap
        new_y = parent.center_y - room_height / 2
      end

      room.bounds = {
        'x1' => new_x,
        'y1' => new_y,
        'x2' => new_x + room_width - 1,
        'y2' => new_y + room_height - 1
      }
      room.center_x = new_x + room_width / 2
      room.center_y = new_y + room_height / 2
    end

    def connect_rooms(rooms, layout_style)
      return if rooms.size < 2

      case layout_style
      when :linear, :vertical
        # Connect in sequence
        rooms.each_cons(2) do |room_a, room_b|
          add_connection(room_a, room_b)
        end
      else
        # Connect to nearest unconnected room
        connected = [rooms.first]
        unconnected = rooms[1..]

        while unconnected.any?
          # Find closest pair
          best_pair = nil
          best_distance = Float::INFINITY

          connected.each do |c|
            unconnected.each do |u|
              dist = distance(c, u)
              if dist < best_distance
                best_distance = dist
                best_pair = [c, u]
              end
            end
          end

          if best_pair
            add_connection(best_pair[0], best_pair[1])
            connected << best_pair[1]
            unconnected.delete(best_pair[1])
          else
            break
          end
        end
      end
    end

    def add_connection(room_a, room_b)
      direction = determine_direction(room_a, room_b)
      opposite = opposite_direction(direction)

      room_a.connections << {
        'direction' => direction,
        'target_room_id' => room_b.room_id,
        'door_type' => 'closed'
      }

      room_b.connections << {
        'direction' => opposite,
        'target_room_id' => room_a.room_id,
        'door_type' => 'closed'
      }
    end

    def determine_direction(from, to)
      dx = to.center_x - from.center_x
      dy = to.center_y - from.center_y

      if dx.abs > dy.abs
        dx > 0 ? 'east' : 'west'
      else
        dy > 0 ? 'south' : 'north'
      end
    end

    def opposite_direction(direction)
      { 'north' => 'south', 'south' => 'north', 'east' => 'west', 'west' => 'east' }[direction]
    end

    def distance(room_a, room_b)
      Math.sqrt((room_a.center_x - room_b.center_x)**2 + (room_a.center_y - room_b.center_y)**2)
    end

    def place_doors(rooms, template)
      rooms.each do |room|
        room.connections.each do |conn|
          # Determine door type based on room types and difficulty
          conn['door_type'] = determine_door_type(room, conn, template)
        end
      end
    end

    def determine_door_type(room, connection, template)
      # Trap rooms often have locked doors
      return 'locked' if room.room_type == 'trap' && rand < 0.5

      # Boss rooms usually locked
      return 'locked' if room.room_type == 'boss' && rand < 0.7

      # Treasure rooms often secret or locked
      if room.room_type == 'treasure'
        return rand < 0.3 ? 'secret' : 'locked'
      end

      # Random based on trap density
      case template[:trap_density]
      when :high
        rand < 0.3 ? 'locked' : 'closed'
      when :medium
        rand < 0.15 ? 'locked' : 'closed'
      else
        'closed'
      end
    end

    def convert_to_tiles(rooms)
      # Initialize empty grid
      dungeon_map.initialize_grid

      # Draw each room
      rooms.each do |room|
        draw_room(room)
      end

      # Draw corridors between connected rooms
      rooms.each do |room|
        room.connections.each do |conn|
          target = rooms.find { |r| r.room_id == conn['target_room_id'] }
          draw_corridor(room, target, conn) if target && room.room_id < target.room_id
        end
      end

      # Save rooms to database
      rooms.each(&:save!)

      dungeon_map.save!
    end

    def draw_room(room)
      # Draw walls
      (room.bounds['y1']..room.bounds['y2']).each do |y|
        (room.bounds['x1']..room.bounds['x2']).each do |x|
          next if x < 0 || y < 0 || x >= dungeon_map.width || y >= dungeon_map.height

          is_edge = x == room.bounds['x1'] || x == room.bounds['x2'] ||
                    y == room.bounds['y1'] || y == room.bounds['y2']

          tile_type = is_edge ? 'wall' : 'floor'
          dungeon_map.set_tile(x, y, tile_type, room_id: room.room_id)
        end
      end
    end

    def draw_corridor(room_a, room_b, connection)
      # Simple L-shaped corridor
      x1 = room_a.center_x
      y1 = room_a.center_y
      x2 = room_b.center_x
      y2 = room_b.center_y

      # Draw horizontal then vertical
      ([x1, x2].min..[x1, x2].max).each do |x|
        next if x < 0 || x >= dungeon_map.width

        dungeon_map.set_tile(x, y1, 'floor')
      end

      ([y1, y2].min..[y1, y2].max).each do |y|
        next if y < 0 || y >= dungeon_map.height

        dungeon_map.set_tile(x2, y, 'floor')
      end

      # Place door at room_a's edge
      door_x, door_y = door_position(room_a, connection['direction'])
      dungeon_map.set_tile(door_x, door_y, "door_#{connection['door_type']}") if door_x && door_y
    end

    def door_position(room, direction)
      case direction
      when 'north'
        [room.center_x, room.bounds['y1']]
      when 'south'
        [room.center_x, room.bounds['y2']]
      when 'east'
        [room.bounds['x2'], room.center_y]
      when 'west'
        [room.bounds['x1'], room.center_y]
      end
    end
  end
end
