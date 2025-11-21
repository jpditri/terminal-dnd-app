# frozen_string_literal: true

module Terminal
  # Manages room definitions, transitions, and context-specific rules
  # Implements the "room metaphor" for flexible state management
  class RoomManager
    attr_reader :session

    # Room definitions with their characteristics
    ROOMS = {
      lobby: {
        name: 'Lobby',
        description: 'Welcome area for character browsing and creation',
        allows_char_edit: true,
        auto_lock_character: false,
        dm_guidance: 'Be welcoming. Help players create or select characters. Describe the world they will enter.'
      },
      character_creation: {
        name: 'Character Creation',
        description: 'Guided character creation process',
        allows_char_edit: true,
        auto_lock_character: false,
        dm_guidance: 'Guide through character creation. Be patient and helpful. Ask questions to understand player vision.'
      },
      tavern: {
        name: 'The Rusty Flagon Tavern',
        description: 'A cozy tavern where adventures begin',
        allows_char_edit: false,
        auto_lock_character: true,
        dm_guidance: 'Describe the tavern atmosphere, NPCs, rumours. This is where adventures start.'
      },
      town: {
        name: 'Town Square',
        description: 'A bustling medieval town',
        allows_char_edit: false,
        auto_lock_character: true,
        dm_guidance: 'Describe shops, NPCs, town events. Players can shop, gather information, take quests.'
      },
      wilderness: {
        name: 'The Wilderness',
        description: 'Forests, roads, and open country',
        allows_char_edit: false,
        auto_lock_character: true,
        dm_guidance: 'Describe terrain, weather, encounters. Emphasize exploration and survival.'
      },
      dungeon: {
        name: 'Ancient Dungeon',
        description: 'Dark corridors and mysterious chambers',
        allows_char_edit: false,
        auto_lock_character: true,
        dm_guidance: 'Describe rooms, traps, monsters. Build tension. Reward careful exploration.'
      },
      combat: {
        name: 'Combat',
        description: 'Active combat encounter',
        allows_char_edit: false,
        auto_lock_character: true,
        hard_lock: true,
        dm_guidance: 'Focus on tactics and mechanics. Describe action vividly. Track initiative and positioning.'
      },
      character_sheet_view: {
        name: 'Character Sheet',
        description: 'Readonly character inspection',
        allows_char_edit: false,
        auto_lock_character: false,
        meta_room: true,
        dm_guidance: 'This is a meta room for viewing stats. Players should use /back to return.'
      }
    }.freeze

    def initialize(session)
      @session = session
    end

    # Get current room definition
    def current_room
      ROOMS[session.current_room&.to_sym] || ROOMS[:lobby]
    end

    # Check if character can be edited in current room
    def can_edit_character?
      return true if current_room[:allows_char_edit]
      return false if current_room[:hard_lock]

      # Even if room doesn't allow editing, can request approval
      !session.character_locked
    end

    # Transition to a new room
    def transition_to(room_name, options = {})
      room_name = room_name.to_sym
      return false unless ROOMS.key?(room_name)

      # Save current room to history unless it's a meta room
      unless current_room[:meta_room]
        history = session.room_history || []
        history.push(session.current_room)
        session.update!(room_history: history.last(10)) # Keep last 10 rooms
      end

      # Update current room
      session.update!(current_room: room_name.to_s)

      # Auto-lock character if room requires it
      if ROOMS[room_name][:auto_lock_character] && !session.character_locked
        lock_character!(reason: "Entering #{ROOMS[room_name][:name]}")
      end

      # Start game timestamp if transitioning from lobby/creation to gameplay
      if game_room?(room_name) && session.game_started_at.nil?
        session.update!(game_started_at: Time.current)
      end

      true
    end

    # Return to previous room
    def go_back
      history = session.room_history || []
      return false if history.empty?

      previous_room = history.pop
      session.update!(
        current_room: previous_room,
        room_history: history
      )

      true
    end

    # Lock character for gameplay
    def lock_character!(reason: nil)
      return if session.character_locked

      session.update!(
        character_locked: true,
        game_started_at: Time.current
      )

      Rails.logger.info "Character locked for session #{session.id}: #{reason}"
    end

    # Unlock character (requires approval in game)
    def unlock_character!(force: false)
      return unless session.character_locked

      # If in lobby, always allow unlock
      if session.current_room == 'lobby' || force
        session.update!(character_locked: false)
        Rails.logger.info "Character unlocked for session #{session.id}#{force ? ' (forced)' : ''}"
        true
      else
        # In game, requires approval
        false
      end
    end

    # Check if room is a game play room (not lobby/creation/meta)
    def game_room?(room = nil)
      room_key = (room || session.current_room).to_sym
      room_def = ROOMS[room_key]

      return false if room_def.nil?
      return false if room_def[:allows_char_edit]
      return false if room_def[:meta_room]

      true
    end

    # Get room-specific DM guidance
    def dm_guidance
      current_room[:dm_guidance]
    end

    # Get suggested quick actions for current room
    def room_quick_actions
      case session.current_room
      when 'lobby'
        [
          { action_type: 'send_message', label: 'Create Character', params: { message: 'I want to create a character' } },
          { action_type: 'send_message', label: 'Browse Characters', params: { message: 'show my characters' } }
        ]
      when 'character_creation'
        [
          { action_type: 'send_message', label: 'Fighter', params: { message: 'Make me a fighter' } },
          { action_type: 'send_message', label: 'Wizard', params: { message: 'Make me a wizard' } },
          { action_type: 'send_message', label: 'Rogue', params: { message: 'Make me a rogue' } }
        ]
      when 'tavern', 'town'
        [
          { action_type: 'send_message', label: 'Look Around', params: { message: 'I look around the room' } },
          { action_type: 'send_message', label: 'Talk to Bartender', params: { message: 'I approach the bartender' } },
          { action_type: 'send_message', label: 'Listen for Rumors', params: { message: 'I listen for interesting rumors' } }
        ]
      when 'combat'
        [
          { action_type: 'send_message', label: 'Attack', params: { message: 'I attack!' } },
          { action_type: 'send_message', label: 'Defend', params: { message: 'I take the dodge action' } },
          { action_type: 'send_message', label: 'Cast Spell', params: { message: 'I cast a spell' } }
        ]
      else
        []
      end
    end
  end
end
