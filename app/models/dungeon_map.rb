# frozen_string_literal: true

# Persistent dungeon map with ASCII and graphical rendering support
class DungeonMap < ApplicationRecord
  include Discard::Model
  has_paper_trail

  # Relationships
  belongs_to :solo_session
  belongs_to :map_template, optional: true
  has_many :map_rooms, dependent: :destroy
  has_many :party_positions, dependent: :destroy
  has_many :map_exports, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :width, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 200 }
  validates :height, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 200 }
  validates :fog_of_war_mode, inclusion: { in: %w[full partial none] }

  # Scopes
  scope :active, -> { kept }
  scope :for_session, ->(session_id) { where(solo_session_id: session_id) }

  # Tile type constants
  TILE_TYPES = {
    floor: '.',
    wall: '#',
    door: '+',
    door_open: '/',
    door_locked: 'X',
    door_secret: 'S',
    stairs_up: '<',
    stairs_down: '>',
    trap: '^',
    trap_disabled: 'v',
    chest: '$',
    chest_open: 'c',
    water: '~',
    pit: 'O',
    pillar: 'o',
    altar: 'T',
    statue: '&',
    player: '@',
    npc: 'N',
    enemy: 'E',
    boss: 'B',
    empty: ' ',
    unknown: '?'
  }.freeze

  # Get tile at position
  def tile_at(x, y)
    tile_data.find { |t| t['x'] == x && t['y'] == y }
  end

  # Set tile at position
  def set_tile(x, y, type, **attributes)
    tile = tile_at(x, y)
    if tile
      tile.merge!('type' => type.to_s, **attributes.stringify_keys)
    else
      tile_data << { 'x' => x, 'y' => y, 'type' => type.to_s, **attributes.stringify_keys }
    end
    save!
  end

  # Mark tile as visited
  def visit_tile(x, y)
    tile = tile_at(x, y)
    return unless tile

    tile['visited'] = true
    tile['revealed'] = true
    save!
  end

  # Reveal tile without visiting
  def reveal_tile(x, y)
    tile = tile_at(x, y)
    return unless tile

    tile['revealed'] = true
    save!
  end

  # Get room at position
  def room_at(x, y)
    map_rooms.find do |room|
      bounds = room.bounds
      x >= bounds['x1'] && x <= bounds['x2'] &&
        y >= bounds['y1'] && y <= bounds['y2']
    end
  end

  # Get current party position
  def party_position
    party_positions.find_by(character_id: nil) || party_positions.first
  end

  # Initialize empty grid
  def initialize_grid
    self.tile_data = []
    (0...height).each do |y|
      (0...width).each do |x|
        tile_data << {
          'x' => x,
          'y' => y,
          'type' => 'empty',
          'visited' => false,
          'revealed' => false
        }
      end
    end
  end

  # Get all visited rooms
  def visited_rooms
    map_rooms.where(visited: true)
  end

  # Get unexplored connections from current position
  def unexplored_connections
    current_room = room_at(party_position&.x, party_position&.y)
    return [] unless current_room

    current_room.connections.reject do |conn|
      target_room = map_rooms.find_by(room_id: conn['target_room_id'])
      target_room&.visited?
    end
  end

  # Export configuration
  def to_export_hash
    {
      id: id,
      name: name,
      dimensions: { width: width, height: height },
      template_type: template_type,
      fog_of_war_mode: fog_of_war_mode,
      rooms: map_rooms.map(&:to_export_hash),
      tiles: tile_data,
      metadata: metadata,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
