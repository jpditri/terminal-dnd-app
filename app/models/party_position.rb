# frozen_string_literal: true

# Tracks party or individual character position on the dungeon map
class PartyPosition < ApplicationRecord
  # Relationships
  belongs_to :dungeon_map
  belongs_to :character, optional: true
  belongs_to :current_room, class_name: 'MapRoom', optional: true

  # Validations
  validates :x, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :y, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :dungeon_map_id, uniqueness: { scope: :character_id }
  validates :facing, inclusion: { in: %w[north south east west] }

  # Directions
  DIRECTIONS = {
    'north' => [0, -1],
    'south' => [0, 1],
    'east' => [1, 0],
    'west' => [-1, 0]
  }.freeze

  OPPOSITE_DIRECTIONS = {
    'north' => 'south',
    'south' => 'north',
    'east' => 'west',
    'west' => 'east'
  }.freeze

  # Move to absolute position
  def move_to(new_x, new_y)
    record_movement
    update!(x: new_x, y: new_y, last_moved_at: Time.current)
    update_current_room
  end

  # Move in direction
  def move_direction(direction)
    delta = DIRECTIONS[direction]
    return false unless delta

    new_x = x + delta[0]
    new_y = y + delta[1]

    return false unless valid_position?(new_x, new_y)

    move_to(new_x, new_y)
    update!(facing: direction)
    true
  end

  # Turn to face direction
  def turn(direction)
    return false unless DIRECTIONS.key?(direction)

    update!(facing: direction)
    true
  end

  # Get position in front of party
  def position_ahead
    delta = DIRECTIONS[facing]
    [x + delta[0], y + delta[1]]
  end

  # Check if position is valid (within bounds and not blocked)
  def valid_position?(check_x, check_y)
    return false if check_x < 0 || check_y < 0
    return false if check_x >= dungeon_map.width || check_y >= dungeon_map.height

    tile = dungeon_map.tile_at(check_x, check_y)
    return false unless tile

    # Can't move through walls or pits
    !%w[wall pit empty].include?(tile['type'])
  end

  # Get adjacent positions (orthogonal only)
  def adjacent_positions
    DIRECTIONS.map do |_dir, delta|
      [x + delta[0], y + delta[1]]
    end.select { |pos| valid_position?(pos[0], pos[1]) }
  end

  # Get valid move directions
  def valid_moves
    DIRECTIONS.select do |_dir, delta|
      valid_position?(x + delta[0], y + delta[1])
    end.keys
  end

  # Undo last movement
  def undo_move
    return false if movement_history.empty?

    last_position = movement_history.pop
    update!(
      x: last_position['x'],
      y: last_position['y'],
      movement_history: movement_history
    )
    update_current_room
    true
  end

  # Clear movement history
  def clear_history
    update!(movement_history: [])
  end

  # Distance to another position
  def distance_to(other_x, other_y)
    Math.sqrt((x - other_x)**2 + (y - other_y)**2)
  end

  # Manhattan distance (grid-based)
  def manhattan_distance_to(other_x, other_y)
    (x - other_x).abs + (y - other_y).abs
  end

  private

  # Record current position in history
  def record_movement
    movement_history << { 'x' => x, 'y' => y, 'timestamp' => Time.current.iso8601 }

    # Keep only last 100 movements
    self.movement_history = movement_history.last(100) if movement_history.size > 100
  end

  # Update current room reference based on position
  def update_current_room
    room = dungeon_map.room_at(x, y)
    update!(current_room: room) if room != current_room
  end
end
