# frozen_string_literal: true

module Terminal
  # Command preprocessor for instant responses and command routing
  # Handles shortcuts, validates room context, and provides fast-path for common commands
  class CommandPreprocessor
    attr_reader :session, :message, :character

    # Command shortcuts that expand to full commands
    SHORTCUTS = {
      'i' => 'show inventory',
      'inv' => 'show inventory',
      's' => 'show character sheet',
      'stats' => 'show character sheet',
      'sheet' => 'show character sheet',
      'h' => 'help',
      '?' => 'help',
      'm' => 'show map',
      'map' => 'show map',
      'l' => 'look around carefully',
      'look' => 'look around carefully'
    }.freeze

    # Commands that always work regardless of room (escape hatches)
    ALWAYS_ALLOWED = %w[help quit save back goto].freeze

    def initialize(session, message)
      @session = session
      @message = message.to_s.strip
      @character = session.character
    end

    # Check if this command can be handled instantly without LLM
    def instant_response?
      instant_command.present?
    end

    # Get the instant response data
    def instant_result
      case instant_command
      when :inventory
        inventory_response
      when :character_sheet
        character_sheet_response
      when :help
        help_response
      when :map
        map_response
      else
        nil
      end
    end

    # Check if command is soft-blocked (warn but allow)
    def soft_blocked?
      return false if escape_hatch?
      return false unless session.current_room

      blocking_reason.present?
    end

    # Get the soft block warning message
    def warning_message
      blocking_reason
    end

    # Check if this is simple intent that could use cheaper model
    def simple_intent?
      return true if SHORTCUTS.key?(normalized_message)
      return true if simple_dialogue?
      return true if simple_exploration?

      false
    end

    # Expand shortcuts to full commands
    def expanded_message
      SHORTCUTS[normalized_message] || message
    end

    private

    def normalized_message
      message.downcase.strip
    end

    def instant_command
      case normalized_message
      when 'i', 'inv', 'inventory'
        character ? :inventory : nil
      when 's', 'stats', 'sheet', 'character sheet', 'show character sheet'
        character ? :character_sheet : nil
      when 'h', '?', 'help'
        :help
      when 'm', 'map', 'show map'
        :map
      else
        nil
      end
    end

    def escape_hatch?
      ALWAYS_ALLOWED.any? { |cmd| normalized_message.start_with?(cmd) }
    end

    def blocking_reason
      return nil if session.current_room == 'lobby'

      # Check for character editing attempts when locked
      if session.character_locked && character_edit_attempt?
        "Your character is locked for gameplay. Use `/unlock` to request DM approval for changes."
      # Check for combat commands outside combat
      elsif !in_combat? && combat_command?
        "You're not in combat. Did you mean to explore or interact?"
      # Check for inappropriate room transitions
      elsif inappropriate_room_command?
        "That action doesn't make sense in #{session.current_room}. Try `/goto` to change context."
      else
        nil
      end
    end

    def character_edit_attempt?
      edit_keywords = ['change class', 'change race', 'reroll', 'modify stats', 'set ability']
      edit_keywords.any? { |keyword| normalized_message.include?(keyword) }
    end

    def combat_command?
      combat_keywords = ['attack', 'defend', 'initiative', 'damage', 'hit points']
      combat_keywords.any? { |keyword| normalized_message.include?(keyword) }
    end

    def in_combat?
      session.mode == 'combat' || session.current_room == 'combat'
    end

    def inappropriate_room_command?
      # Could add more sophisticated logic here
      false
    end

    def simple_dialogue?
      # Simple greetings or yes/no responses
      simple_patterns = [/^(yes|no|ok|sure|thanks|hello|hi|bye)$/i]
      simple_patterns.any? { |pattern| normalized_message =~ pattern }
    end

    def simple_exploration?
      # Basic look/search commands
      exploration_patterns = [/^look (at|around|for)/, /^search/, /^examine/]
      exploration_patterns.any? { |pattern| normalized_message =~ pattern }
    end

    # Instant response builders
    def inventory_response
      items = character.character_inventories.includes(:item).map do |inv|
        item = inv.item
        "#{item.name} (#{inv.quantity}x)" + (item.weight ? " - #{item.weight} lb" : '')
      end

      {
        type: 'instant_response',
        command: 'inventory',
        content: items.any? ? items.join("\n") : 'Your inventory is empty.',
        display_in: 'side_panel',
        title: "#{character.name}'s Inventory"
      }
    end

    def character_sheet_response
      {
        type: 'instant_response',
        command: 'character_sheet',
        character: character_data,
        display_in: 'side_panel',
        title: "#{character.name} - Character Sheet"
      }
    end

    def help_response
      {
        type: 'instant_response',
        command: 'help',
        content: help_text,
        display_in: 'narrative'
      }
    end

    def map_response
      {
        type: 'instant_response',
        command: 'map',
        content: 'Map display not yet implemented',
        display_in: 'narrative'
      }
    end

    def character_data
      return nil unless character

      {
        id: character.id,
        name: character.name,
        race: character.race&.name,
        class: character.character_class&.name,
        level: character.level,
        hp: character.hit_points_current,
        max_hp: character.hit_points_max,
        ac: character.calculated_armor_class,
        gold: character.gold,
        xp: character.experience,
        conditions: character.character_combat_tracker&.active_conditions || []
      }
    end

    def help_text
      <<~HELP
        **Terminal D&D Commands**

        **Character Management:**
        - `/create` - Create a new character
        - `/load [name]` - Load an existing character
        - `/character` or `s` - Show character sheet

        **Gameplay:**
        - `/roll [dice]` - Roll dice (e.g., /roll 1d20)
        - `/inventory` or `i` - Check your inventory
        - `/rest [short|long]` - Take a rest

        **Navigation:**
        - `/map` or `m` - Show current map
        - `/back` - Return to previous context
        - `/goto [room]` - Move to a different context

        **Quick Shortcuts:**
        - `i` - Inventory
        - `s` - Character sheet
        - `h` or `?` - This help
        - `l` - Look around

        **Other:**
        - `/save` - Save your game
        - `/quit` - Exit the game

        Or just type naturally to interact with the AI Dungeon Master!
      HELP
    end
  end
end
