# frozen_string_literal: true

# Tracks a terminal-style D&D session
class TerminalSession < ApplicationRecord
  include Discard::Model
  has_paper_trail

  # Relationships
  belongs_to :user
  belongs_to :character, optional: true
  belongs_to :solo_session, optional: true
  belongs_to :dungeon_map, optional: true
  belongs_to :campaign, optional: true

  has_many :narrative_outputs, dependent: :destroy
  has_many :quick_actions, dependent: :destroy

  # Validations
  validates :session_token, presence: true, uniqueness: true
  validates :mode, inclusion: { in: %w[creation exploration combat dialogue rest] }
  validates :map_render_mode, inclusion: { in: %w[ascii svg sprite] }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :for_user, ->(user) { where(user: user) }

  # Callbacks
  before_validation :generate_session_token, on: :create
  after_create :ensure_campaign

  # Session modes
  MODES = {
    creation: 'Character creation',
    exploration: 'Exploring',
    combat: 'In combat',
    dialogue: 'Talking',
    rest: 'Resting'
  }.freeze

  # Add command to history
  def add_to_history(command)
    command_history << command
    self.command_history = command_history.last(100) # Keep last 100
    save!
  end

  # Get recent narrative
  def recent_narrative(limit = 50)
    narrative_outputs.order(created_at: :desc).limit(limit).reverse
  end

  # Get current quick actions based on state
  def current_actions
    quick_actions.where(is_available: true).order(:sort_order)
  end

  # Update quick actions
  def update_quick_actions(actions)
    quick_actions.destroy_all

    actions.each_with_index do |action, i|
      quick_actions.create!(
        label: action[:label],
        action_type: action[:action_type],
        target_type: action[:target_type],
        target_id: action[:target_id],
        params: action[:params] || {},
        tooltip: action[:tooltip],
        keyboard_shortcut: (i + 1).to_s,
        sort_order: i,
        requires_roll: action[:requires_roll] || false,
        skill_check: action[:skill_check],
        dc: action[:dc]
      )
    end
  end

  # Add narrative output
  def add_narrative(content, content_type: 'narrative', **options)
    narrative_outputs.create!(
      content: content,
      content_type: content_type,
      clickable_elements: options[:clickables] || [],
      memory_hints: options[:memory_hints] || [],
      speaker: options[:speaker],
      related_room_id: options[:room_id],
      related_npc_id: options[:npc_id]
    )
  end

  # Change mode
  def change_mode(new_mode)
    return false unless MODES.key?(new_mode.to_sym)

    update!(mode: new_mode)
  end

  # Room management methods
  def room_manager
    @room_manager ||= Terminal::RoomManager.new(self)
  end

  def transition_to_room(room_name)
    room_manager.transition_to(room_name)
  end

  def go_back
    room_manager.go_back
  end

  def lock_character!(reason: nil)
    room_manager.lock_character!(reason: reason)
  end

  def unlock_character!(force: false)
    room_manager.unlock_character!(force: force)
  end

  def can_edit_character?
    room_manager.can_edit_character?
  end

  def in_game_room?
    room_manager.game_room?
  end

  private

  def generate_session_token
    self.session_token ||= SecureRandom.hex(16)
  end

  def ensure_campaign
    return if campaign.present?

    # Create a campaign for this terminal session
    self.campaign = Campaign.create!(
      name: "Terminal Session - #{user.username || user.email}",
      description: "Auto-generated campaign for terminal/solo play",
      created_at: Time.current
    )
    save!
  end
end
