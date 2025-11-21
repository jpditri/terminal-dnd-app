# frozen_string_literal: true

# Individual room within a dungeon map with AI-generated content
class MapRoom < ApplicationRecord
  has_paper_trail

  # Relationships
  belongs_to :dungeon_map
  has_many :npcs, foreign_key: :current_room_id, dependent: :nullify

  # Validations
  validates :room_id, presence: true, uniqueness: { scope: :dungeon_map_id }
  validates :room_type, presence: true
  validates :bounds, presence: true

  # Room type constants
  ROOM_TYPES = %w[
    entrance
    corridor
    chamber
    hallway
    intersection
    stairs
    treasure
    trap
    boss
    shrine
    library
    armory
    prison
    kitchen
    bedroom
    throne
    laboratory
    crypt
    natural_cave
    pool
  ].freeze

  # Door type constants
  DOOR_TYPES = %w[
    open
    closed
    locked
    barred
    secret
    trapped
    magical
    archway
  ].freeze

  validates :room_type, inclusion: { in: ROOM_TYPES }

  # Scopes
  scope :visited, -> { where(visited: true) }
  scope :unvisited, -> { where(visited: false) }
  scope :cleared, -> { where(cleared: true) }
  scope :with_treasure, -> { where(looted: false).where("contents->>'items' IS NOT NULL") }
  scope :with_enemies, -> { where("contents->>'enemies' IS NOT NULL") }

  # Mark room as visited and trigger content generation if needed
  def visit!
    return if visited?

    update!(visited: true)
    generate_content_if_needed
  end

  # Mark room as cleared (all enemies defeated)
  def clear!
    update!(cleared: true)
  end

  # Mark room as looted (all treasure collected)
  def loot!
    update!(looted: true)
  end

  # Get center point of room
  def center
    return [center_x, center_y] if center_x && center_y

    [
      (bounds['x1'] + bounds['x2']) / 2,
      (bounds['y1'] + bounds['y2']) / 2
    ]
  end

  # Get all tiles that belong to this room
  def tiles
    dungeon_map.tile_data.select do |tile|
      tile['x'] >= bounds['x1'] && tile['x'] <= bounds['x2'] &&
        tile['y'] >= bounds['y1'] && tile['y'] <= bounds['y2']
    end
  end

  # Get dimensions
  def width
    bounds['x2'] - bounds['x1'] + 1
  end

  def height
    bounds['y2'] - bounds['y1'] + 1
  end

  def area
    width * height
  end

  # Check if position is within room
  def contains?(x, y)
    x >= bounds['x1'] && x <= bounds['x2'] &&
      y >= bounds['y1'] && y <= bounds['y2']
  end

  # Get connected rooms
  def connected_rooms
    return [] if connections.blank?

    room_ids = connections.map { |c| c['target_room_id'] }
    dungeon_map.map_rooms.where(room_id: room_ids)
  end

  # Get connection to specific room
  def connection_to(other_room)
    connections.find { |c| c['target_room_id'] == other_room.room_id }
  end

  # Get enemies in room
  def enemies
    contents['enemies'] || []
  end

  # Get items in room
  def items
    contents['items'] || []
  end

  # Get traps in room
  def traps
    contents['traps'] || []
  end

  # Get features in room
  def features
    contents['features'] || []
  end

  # Add enemy to room
  def add_enemy(enemy_data)
    contents['enemies'] ||= []
    contents['enemies'] << enemy_data
    save!
  end

  # Remove enemy from room
  def remove_enemy(enemy_id)
    return unless contents['enemies']

    contents['enemies'].reject! { |e| e['id'] == enemy_id }
    save!
  end

  # Add item to room
  def add_item(item_data)
    contents['items'] ||= []
    contents['items'] << item_data
    save!
  end

  # Remove item from room
  def remove_item(item_id)
    return unless contents['items']

    contents['items'].reject! { |i| i['id'] == item_id }
    save!
  end

  # Generate content if not already done
  def generate_content_if_needed
    return if description.present?

    # This will be called by MapContentService
    # Placeholder for now
  end

  # Export configuration
  def to_export_hash
    {
      room_id: room_id,
      room_type: room_type,
      name: name,
      bounds: bounds,
      connections: connections,
      center: center,
      description: description,
      contents: contents,
      visited: visited,
      cleared: cleared,
      looted: looted
    }
  end
end
