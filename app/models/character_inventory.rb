# frozen_string_literal: true

# CharacterInventory manages a character's items, equipment, currency, and encumbrance
# Ported from heretical-web-app with adaptations for terminal-dnd
#
# Key Features:
# - Inventory grid management with stacking
# - Equipment slot system (13 slots)
# - Carry capacity and encumbrance (D&D 5e rules)
# - Currency management with conversions
# - Attunement tracking (max 3 items)
# - Equipment sets for quick swapping
# - Weight calculations (50 coins = 1 lb)
#
# IMPORTANT: This model uses JSONB columns for flexible storage.
# When mutating JSONB hashes in place, we MUST call {attribute}_will_change!
# before the mutation to ensure Rails tracks and persists the changes.
class CharacterInventory < ApplicationRecord
  include Discard::Model

  has_paper_trail

  # Associations
  belongs_to :character

  # Validations
  validates :character_id, presence: true, uniqueness: true
  validates :carry_capacity, numericality: { greater_than_or_equal_to: 0 }
  validates :current_weight, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

  # Callbacks
  before_validation :initialize_defaults
  before_validation :calculate_carry_capacity, if: :should_calculate_carry_capacity?
  before_save :recalculate_current_weight

  # JSONB defaults
  attribute :inventory_grid, :jsonb, default: []
  attribute :equipped_items, :jsonb, default: {}
  attribute :equipment_sets, :jsonb, default: {}
  attribute :currency, :jsonb, default: { 'cp' => 0, 'sp' => 0, 'ep' => 0, 'gp' => 0, 'pp' => 0 }

  # ========================================
  # CARRY CAPACITY & ENCUMBRANCE
  # ========================================

  # Calculate carry capacity based on character's Strength
  # Formula: STR × 15
  def calculate_carry_capacity
    return 150 unless character&.strength

    self.carry_capacity = character.strength * 15
  end

  # Recalculate total weight from inventory and equipped items
  def recalculate_current_weight
    total = 0

    # Add weight from inventory grid
    if inventory_grid.is_a?(Array)
      inventory_grid.each do |entry|
        item_id = entry['item_id'] || entry[:item_id]
        quantity = (entry['quantity'] || entry[:quantity] || 1).to_i

        if item_id
          item = Item.find_by(id: item_id)
          total += (item&.weight || 0) * quantity if item
        end
      end
    end

    # Add weight from equipped items
    if equipped_items.is_a?(Hash)
      equipped_items.each do |_slot, item_id|
        next if item_id.blank?

        item = Item.find_by(id: item_id)
        total += (item&.weight || 0) if item
      end
    end

    # Add currency weight (50 coins = 1 lb)
    total += currency_weight if currency.present?

    self.current_weight = total.round(2)
  end

  # Calculate weight of all currency
  # 50 coins (of any type) = 1 lb
  def currency_weight
    return 0 unless currency.is_a?(Hash)

    total_coins = currency.sum do |_type, amount|
      amount.to_i
    end

    (total_coins / 50.0).round(2)
  end

  # Encumbrance status based on D&D 5e rules
  # Normal: 0 to STR×5 (inclusive)
  # Encumbered: > STR×5 to STR×10 (speed -10 ft)
  # Heavily Encumbered: > STR×10 to STR×15 (speed -20 ft, disadvantage)
  # Over Capacity: > STR×15 (Cannot move)
  def encumbrance_status
    strength = character&.strength || 10
    normal_threshold = strength * 5
    encumbered_threshold = strength * 10
    max_capacity = strength * 15

    if current_weight <= normal_threshold
      :normal
    elsif current_weight <= encumbered_threshold
      :encumbered
    elsif current_weight <= max_capacity
      :heavily_encumbered
    else
      :over_capacity
    end
  end

  # Speed penalty based on encumbrance
  def speed_penalty
    case encumbrance_status
    when :encumbered
      10
    when :heavily_encumbered, :over_capacity
      20
    else
      0
    end
  end

  # Color for weight indicator
  def weight_indicator_color
    percentage = (current_weight.to_f / carry_capacity * 100).round

    case percentage
    when 0..66
      'success' # Green
    when 67..90
      'warning' # Yellow
    else
      'danger' # Red
    end
  end

  # Format weight display
  def weight_display
    "#{current_weight}/#{carry_capacity} lbs"
  end

  # ========================================
  # INVENTORY GRID MANAGEMENT
  # ========================================

  # Add item to inventory grid
  def add_item_to_grid(item, quantity = 1, position = nil)
    inventory_grid_will_change!
    self.inventory_grid ||= []

    # Handle nil quantity - default to 1
    quantity ||= 1

    # Check if item is stackable (arrows, potions, etc)
    if item_stackable?(item)
      # Find existing stack
      existing = inventory_grid.find { |entry| entry['item_id'] == item.id }

      if existing
        existing['quantity'] = (existing['quantity'] || 1) + quantity
      else
        inventory_grid << {
          'item_id' => item.id,
          'quantity' => quantity,
          'position' => position || next_available_position
        }
      end
    else
      # For non-stackable items, still store the quantity
      existing = inventory_grid.find { |entry| entry['item_id'] == item.id }

      if existing
        existing['quantity'] = (existing['quantity'] || 1) + quantity
      else
        inventory_grid << {
          'item_id' => item.id,
          'quantity' => quantity,
          'position' => position || next_available_position
        }
      end
    end

    recalculate_current_weight
    save
  end

  # Remove item from inventory grid
  def remove_item_from_grid(item_id, quantity = nil)
    inventory_grid_will_change!
    self.inventory_grid ||= []

    entry = inventory_grid.find { |e| e['item_id'] == item_id }

    if entry
      quantity_to_remove = quantity || entry['quantity']

      if quantity && entry['quantity'] > quantity
        # Reduce stack
        entry['quantity'] -= quantity
      else
        # Remove completely
        inventory_grid.delete(entry)
      end
    end

    recalculate_current_weight
    save
  end

  # Get all items in inventory with details
  def inventory_items
    return [] unless inventory_grid.is_a?(Array)

    inventory_grid.map do |entry|
      item = Item.find_by(id: entry['item_id'])
      next unless item

      {
        item: item,
        quantity: entry['quantity'] || 1,
        position: entry['position'],
        total_weight: (item.weight || 0) * (entry['quantity'] || 1)
      }
    end.compact
  end

  # ========================================
  # EQUIPMENT MANAGEMENT
  # ========================================

  # Equip an item to a specific slot
  def equip_item(item, slot)
    equipped_items_will_change!
    self.equipped_items ||= {}

    # Handle both Item objects and item IDs
    item_id = item.is_a?(Integer) ? item : item.id
    item_obj = item.is_a?(Item) ? item : Item.find_by(id: item_id)

    return false unless item_obj

    # Check equipment compatibility
    compatibility_error = check_equipment_compatibility(item_obj, slot)
    if compatibility_error
      self.last_equipment_error = compatibility_error
      return false
    end

    # Store previously equipped item
    previous_item_id = equipped_items[slot.to_s]

    # Equip new item
    equipped_items[slot.to_s] = item_id

    # Return previous item to inventory if it exists
    if previous_item_id
      previous_item = Item.find_by(id: previous_item_id)
      add_item_to_grid(previous_item) if previous_item
    end

    # If equipping a two-handed weapon, clear off-hand
    if is_two_handed?(item_obj) && slot.to_s == 'main_hand'
      unequip_item('off_hand') if equipped_items['off_hand']
    end

    # Remove from inventory grid
    remove_item_from_grid(item_id, 1)

    recalculate_current_weight
    save
  end

  # Check if equipment is compatible with current setup
  def check_equipment_compatibility(item, slot)
    # Check if trying to equip shield with two-handed weapon
    if slot.to_s == 'off_hand' && equipped_items['main_hand']
      main_hand_item = Item.find_by(id: equipped_items['main_hand'])
      if main_hand_item && is_two_handed?(main_hand_item)
        return "Cannot equip: Two-handed weapon equipped"
      end
    end

    # Check if trying to equip two-handed weapon with shield
    if slot.to_s == 'main_hand' && is_two_handed?(item) && equipped_items['off_hand']
      return "Cannot equip: Off-hand slot occupied"
    end

    nil # No compatibility issues
  end

  # Check if item is two-handed
  def is_two_handed?(item)
    return false unless item

    # Check direct attribute first
    return item.two_handed if item.respond_to?(:two_handed) && item.two_handed.present?

    properties = item.properties || {}
    two_handed_keywords = ['two-handed', 'two handed', 'greatswor', 'greata']

    # Check properties
    return true if properties['two_handed'] == true
    return true if properties['weapon_type']&.downcase&.include?('two')

    # Check name
    two_handed_keywords.any? { |keyword| item.name.downcase.include?(keyword) }
  end

  # Unequip item from slot
  def unequip_item(slot)
    equipped_items_will_change!
    self.equipped_items ||= {}

    item_id = equipped_items[slot.to_s]
    return false unless item_id

    item = Item.find_by(id: item_id)
    return false unless item

    # Remove from equipped
    equipped_items.delete(slot.to_s)

    # Add back to inventory
    add_item_to_grid(item)

    recalculate_current_weight
    save
  end

  # Get all equipped items with details
  def equipped_items_details
    return {} unless equipped_items.is_a?(Hash)

    equipped_items.transform_values do |item_id|
      Item.find_by(id: item_id)
    end.compact
  end

  # Standard equipment slots
  EQUIPMENT_SLOTS = {
    head: 'Head',
    neck: 'Neck',
    chest: 'Chest',
    back: 'Back',
    main_hand: 'Main Hand',
    off_hand: 'Off Hand',
    hands: 'Hands',
    waist: 'Waist',
    legs: 'Legs',
    feet: 'Feet',
    ring_1: 'Ring 1',
    ring_2: 'Ring 2',
    ammunition: 'Ammunition'
  }.freeze

  # ========================================
  # EQUIPMENT SETS
  # ========================================

  # Save current equipment as a named set
  def save_equipment_set(set_name)
    equipment_sets_will_change!
    self.equipment_sets ||= {}

    equipment_sets[set_name] = {
      'equipped_items' => equipped_items.dup,
      'saved_at' => Time.current.to_s
    }

    save
  end

  # Load a saved equipment set
  def load_equipment_set(set_name)
    unless equipment_sets&.key?(set_name)
      return { success: false, error: 'Equipment set not found' }
    end

    saved_set = equipment_sets[set_name]['equipped_items'] || {}
    missing_items = []

    # Unequip current items
    equipped_items_will_change!
    current_equipped = equipped_items.dup
    current_equipped.each do |slot, item_id|
      equipped_items.delete(slot.to_s)

      # Add back to inventory
      item = Item.find_by(id: item_id)
      add_item_to_grid(item) if item
    end

    # Equip items from saved set
    saved_set.each do |slot, item_id|
      item = Item.find_by(id: item_id)

      if item && has_item_in_inventory?(item_id)
        equip_item(item, slot)
      else
        missing_items << item_id
      end
    end

    self.active_set = set_name
    save

    { success: true, missing_items: missing_items }
  end

  # Check if character has item in inventory or equipped
  def has_item_in_inventory?(item_id)
    # Check inventory grid
    in_grid = inventory_grid.is_a?(Array) && inventory_grid.any? { |entry| entry['item_id'] == item_id }

    # Also check if item is currently equipped
    in_equipped = equipped_items.is_a?(Hash) && equipped_items.values.include?(item_id)

    in_grid || in_equipped
  end

  # ========================================
  # CURRENCY MANAGEMENT
  # ========================================

  # Currency conversion rates (base unit: copper)
  CURRENCY_RATES = {
    'cp' => 1,      # Copper
    'sp' => 10,     # Silver = 10 copper
    'ep' => 50,     # Electrum = 50 copper
    'gp' => 100,    # Gold = 100 copper
    'pp' => 1000    # Platinum = 1000 copper
  }.freeze

  # Add currency
  def add_currency(type, amount)
    currency_will_change!
    self.currency ||= { 'cp' => 0, 'sp' => 0, 'ep' => 0, 'gp' => 0, 'pp' => 0 }
    currency[type.to_s] = (currency[type.to_s] || 0) + amount
    save
  end

  # Remove currency
  def remove_currency(type, amount)
    currency_will_change!
    self.currency ||= { 'cp' => 0, 'sp' => 0, 'ep' => 0, 'gp' => 0, 'pp' => 0 }
    current = currency[type.to_s] || 0

    return false if current < amount

    currency[type.to_s] = current - amount
    save
  end

  # Convert currency from one type to another
  def convert_currency(from_type, to_type, amount)
    from_type = from_type.to_s
    to_type = to_type.to_s

    return false unless CURRENCY_RATES.key?(from_type) && CURRENCY_RATES.key?(to_type)
    return false unless (currency[from_type] || 0) >= amount

    # Calculate conversion
    copper_value = amount * CURRENCY_RATES[from_type]
    converted_amount = copper_value / CURRENCY_RATES[to_type]

    # Only allow whole number conversions
    return false if converted_amount != converted_amount.to_i

    # Perform conversion
    remove_currency(from_type, amount)
    add_currency(to_type, converted_amount.to_i)

    true
  end

  # Total wealth in gold pieces
  def total_wealth_in_gp
    return 0 unless currency.is_a?(Hash)

    total_copper = currency.sum do |type, amount|
      (CURRENCY_RATES[type] || 0) * amount
    end

    (total_copper.to_f / CURRENCY_RATES['gp']).round(2)
  end

  # ========================================
  # ATTUNEMENT MANAGEMENT (via character_combat_tracker)
  # ========================================

  MAX_ATTUNEMENT_SLOTS = 3

  # Get attuned items from combat tracker
  def attuned_items
    return [] unless character&.character_combat_tracker

    tracker = character.character_combat_tracker
    resources = tracker.action_resources || {}
    resources['attuned_items'] || []
  end

  # Set attuned items in combat tracker
  def attuned_items=(item_ids)
    return [] unless character&.character_combat_tracker

    tracker = character.character_combat_tracker
    tracker.action_resources_will_change!
    resources = tracker.action_resources || {}
    resources['attuned_items'] = item_ids || []
    tracker.action_resources = resources
    tracker.save!
  end

  # Count of attuned items
  def attuned_count
    attuned_items.size
  end

  # Check if can attune more items
  def can_attune?
    attuned_count < MAX_ATTUNEMENT_SLOTS
  end

  # Attune to an item
  def attune_item(item_id)
    return { success: false, error: 'Attunement limit reached' } unless can_attune?

    item = Item.find_by(id: item_id)
    return { success: false, error: 'Item not found' } unless item
    return { success: false, error: 'Item does not require attunement' } unless item&.requires_attunement

    current = attuned_items
    self.attuned_items = (current + [item_id]).uniq
    { success: true }
  end

  # Unattune from an item
  def unattune_item(item_id)
    current = attuned_items
    self.attuned_items = current - [item_id]
    true
  end

  private

  # Check if item is stackable
  def item_stackable?(item)
    # Items with same name can stack (arrows, potions, etc.)
    %w[arrow bolt potion scroll ammunition].any? { |type| item.name.downcase.include?(type) }
  end

  # Find next available grid position
  def next_available_position
    return 0 if inventory_grid.empty?

    max_position = inventory_grid.map { |e| e['position'] || 0 }.max
    max_position + 1
  end

  # Check if character is present
  def character_present?
    character.present?
  end

  # Check if carry capacity should be calculated
  def should_calculate_carry_capacity?
    character_present? && !carry_capacity_changed?
  end

  # Initialize default values
  def initialize_defaults
    self.inventory_grid ||= []
    self.equipped_items ||= {}
    self.equipment_sets ||= {}
    self.currency ||= { 'cp' => 0, 'sp' => 0, 'ep' => 0, 'gp' => 0, 'pp' => 0 }
    self.current_weight ||= 0
    self.carry_capacity ||= 150
  end
end