# frozen_string_literal: true

module Terminal
  # Generates narrative responses and processes player input
  # Uses AI to create immersive D&D experience
  class TerminalNarrativeService
    attr_reader :session, :character, :ai_client

    def initialize(session, character = nil)
      @session = session
      @character = character || session.character
      @ai_client = AiClientService.new
    end

    # Process natural language input from player
    def process_player_input(input, game_state)
      # Parse intent from input
      intent = parse_player_intent(input)

      case intent[:type]
      when :movement
        handle_movement(intent[:direction], game_state)
      when :attack
        handle_attack(intent[:target], game_state)
      when :talk
        handle_dialogue(intent[:target], game_state)
      when :investigate
        handle_investigation(intent[:target], game_state)
      when :use
        handle_item_use(intent[:item], intent[:target], game_state)
      when :cast
        handle_spell_cast(intent[:spell], intent[:target], game_state)
      when :search
        handle_search(game_state)
      else
        # Let AI interpret and respond
        generate_ai_response(input, game_state)
      end
    end

    # Execute a specific action
    def execute_action(action_type, target_id, params)
      case action_type.to_sym
      when :move
        handle_movement(params[:direction], current_game_state)
      when :investigate
        handle_investigation(target_id, current_game_state)
      when :attack
        handle_attack(target_id, current_game_state)
      when :talk
        handle_dialogue(target_id, current_game_state)
      when :use
        handle_item_use(params[:item_id], target_id, current_game_state)
      when :cast
        handle_spell_cast(params[:spell_id], target_id, current_game_state)
      when :take
        handle_take_item(target_id, current_game_state)
      when :open
        handle_open(target_id, current_game_state)
      else
        Result.failure(:unknown_action)
      end
    end

    # Generate scene description for current location
    def generate_scene_description(game_state)
      room = current_room(game_state)
      return Result.failure(:no_room) unless room

      # Check if room already has description
      if room.description.present?
        return Result.success(
          entry_type: 'dm',
          text: room.description,
          clickables: room.clickable_elements,
          quick_actions: generate_quick_actions(room, game_state)
        )
      end

      # Generate description via AI
      context = build_scene_context(room, game_state)
      prompt = build_scene_prompt(room, context)

      response = ai_client.generate(prompt, system: system_prompt)

      if response.success?
        # Parse response for clickables
        parsed = parse_description_for_clickables(response.value)

        # Save to room
        room.update!(
          description: parsed[:text],
          clickable_elements: parsed[:clickables]
        )

        Result.success(
          entry_type: 'dm',
          text: parsed[:text],
          clickables: parsed[:clickables],
          quick_actions: generate_quick_actions(room, game_state)
        )
      else
        Result.failure(response.error)
      end
    end

    # Start dialogue with NPC
    def start_dialogue(npc)
      context = build_npc_context(npc)
      prompt = "#{npc.name} sees #{character.name} approaching. Generate their greeting based on their personality: #{npc.personality_traits.join(', ')}."

      response = ai_client.generate(prompt, system: npc_system_prompt(npc))

      if response.success?
        Result.success(
          entry_type: 'dialogue',
          text: response.value,
          speaker: npc.name,
          quick_actions: dialogue_actions(npc)
        )
      else
        # Fallback to generic greeting
        Result.success(
          entry_type: 'dialogue',
          text: "\"Hello there, traveler,\" #{npc.name} says.",
          speaker: npc.name,
          quick_actions: dialogue_actions(npc)
        )
      end
    end

    # Initiate combat
    def initiate_combat(enemies)
      enemy_names = enemies.map(&:name).join(', ')

      session.change_mode('combat')

      Result.success(
        entry_type: 'dm',
        text: "Combat begins! You face: #{enemy_names}. Roll for initiative!",
        quick_actions: combat_actions
      )
    end

    # Interact with object
    def interact_with_object(object_id, action)
      room = current_room(current_game_state)
      return Result.failure(:no_room) unless room

      # Find object in room contents
      object = room.features.find { |f| f['id'] == object_id }
      object ||= room.items.find { |i| i['id'] == object_id }

      return Result.failure(:object_not_found) unless object

      case action
      when 'examine', 'investigate'
        generate_object_description(object, room)
      when 'use'
        use_object(object, room)
      when 'search'
        search_object(object, room)
      else
        generate_object_description(object, room)
      end
    end

    # Interact with item
    def interact_with_item(item_id, action)
      case action
      when 'take'
        handle_take_item(item_id, current_game_state)
      when 'examine'
        generate_item_description(item_id)
      when 'use'
        handle_item_use(item_id, nil, current_game_state)
      else
        generate_item_description(item_id)
      end
    end

    # Travel to location
    def travel_to_location(location_id)
      # This would handle map/world travel
      Result.success(
        entry_type: 'dm',
        text: "You begin your journey...",
        quick_actions: []
      )
    end

    private

    def current_game_state
      session.solo_session&.current_game_state || SoloGameState.new
    end

    def current_room(game_state)
      return nil unless session.dungeon_map

      party_pos = session.dungeon_map.party_position
      return nil unless party_pos

      session.dungeon_map.room_at(party_pos.x, party_pos.y)
    end

    def parse_player_intent(input)
      input_lower = input.downcase

      # Movement patterns
      if input_lower.match?(/\b(go|move|walk|head|travel)\s+(north|south|east|west|n|s|e|w)\b/i)
        direction = input_lower.match(/north|south|east|west|n|s|e|w/i)[0]
        direction = { 'n' => 'north', 's' => 'south', 'e' => 'east', 'w' => 'west' }[direction] || direction
        return { type: :movement, direction: direction }
      end

      # Attack patterns
      if input_lower.match?(/\b(attack|hit|strike|fight|kill)\b/)
        target = extract_target(input)
        return { type: :attack, target: target }
      end

      # Talk patterns
      if input_lower.match?(/\b(talk|speak|ask|tell|say)\b/)
        target = extract_target(input)
        return { type: :talk, target: target }
      end

      # Investigation patterns
      if input_lower.match?(/\b(investigate|examine|look|inspect|check)\b/)
        target = extract_target(input)
        return { type: :investigate, target: target }
      end

      # Search patterns
      if input_lower.match?(/\b(search|look around|find)\b/)
        return { type: :search }
      end

      # Cast spell patterns
      if input_lower.match?(/\b(cast|use spell)\b/)
        spell = extract_spell(input)
        target = extract_target(input)
        return { type: :cast, spell: spell, target: target }
      end

      # Use item patterns
      if input_lower.match?(/\b(use|drink|eat|apply)\b/)
        item = extract_item(input)
        target = extract_target(input)
        return { type: :use, item: item, target: target }
      end

      # Default to general input
      { type: :general, input: input }
    end

    def extract_target(input)
      # Simple extraction - in real implementation would use NLP
      words = input.split
      if words.include?('the')
        idx = words.index('the')
        words[idx + 1..-1]&.join(' ')
      else
        nil
      end
    end

    def extract_spell(input)
      # Would match against character's known spells
      nil
    end

    def extract_item(input)
      # Would match against inventory
      nil
    end

    def generate_ai_response(input, game_state)
      context = build_context(game_state)
      prompt = "Player says: \"#{input}\"\n\nGenerate an appropriate DM response."

      response = ai_client.generate(prompt, system: system_prompt)

      if response.success?
        parsed = parse_description_for_clickables(response.value)

        Result.success(
          entry_type: 'dm',
          text: parsed[:text],
          clickables: parsed[:clickables],
          quick_actions: generate_quick_actions(current_room(game_state), game_state)
        )
      else
        Result.success(
          entry_type: 'dm',
          text: "The DM considers your action...",
          quick_actions: []
        )
      end
    end

    def handle_movement(direction, game_state)
      return Result.failure(:no_map) unless session.dungeon_map

      service = Maps::PartyMovementService.new(session.dungeon_map)
      result = service.move_direction(direction)

      if result.success?
        # Generate new scene description
        generate_scene_description(game_state)
      else
        Result.success(
          entry_type: 'dm',
          text: "You cannot go that way.",
          quick_actions: generate_quick_actions(current_room(game_state), game_state)
        )
      end
    end

    def handle_attack(target, game_state)
      session.change_mode('combat')

      Result.success(
        entry_type: 'dm',
        text: "You prepare to attack#{target ? " #{target}" : ''}! Roll initiative.",
        quick_actions: combat_actions
      )
    end

    def handle_dialogue(target, game_state)
      if target
        npc = find_npc(target, game_state)
        return start_dialogue(npc) if npc
      end

      Result.success(
        entry_type: 'dm',
        text: "There's no one here to talk to.",
        quick_actions: []
      )
    end

    def handle_investigation(target, game_state)
      room = current_room(game_state)
      return Result.failure(:no_room) unless room

      # Roll investigation
      roll = rand(1..20)
      modifier = character ? ((character.intelligence - 10) / 2) : 0
      total = roll + modifier

      # Generate description based on roll
      if total >= 15
        Result.success(
          entry_type: 'roll',
          text: "Investigation check: #{roll} + #{modifier} = #{total}\n\nYou thoroughly examine #{target || 'the area'} and notice several details...",
          quick_actions: []
        )
      elsif total >= 10
        Result.success(
          entry_type: 'roll',
          text: "Investigation check: #{roll} + #{modifier} = #{total}\n\nYou examine #{target || 'the area'} but find nothing unusual.",
          quick_actions: []
        )
      else
        Result.success(
          entry_type: 'roll',
          text: "Investigation check: #{roll} + #{modifier} = #{total}\n\nYou're not sure what you're looking for.",
          quick_actions: []
        )
      end
    end

    def handle_search(game_state)
      room = current_room(game_state)
      return Result.failure(:no_room) unless room

      # Roll perception
      roll = rand(1..20)
      modifier = character ? ((character.wisdom - 10) / 2) : 0
      total = roll + modifier

      Result.success(
        entry_type: 'roll',
        text: "Perception check: #{roll} + #{modifier} = #{total}\n\nYou search the area carefully...",
        quick_actions: []
      )
    end

    def handle_item_use(item_id, target_id, game_state)
      Result.success(
        entry_type: 'dm',
        text: "You use the item.",
        quick_actions: []
      )
    end

    def handle_spell_cast(spell_id, target_id, game_state)
      Result.success(
        entry_type: 'dm',
        text: "You begin casting the spell...",
        quick_actions: []
      )
    end

    def handle_take_item(item_id, game_state)
      Result.success(
        entry_type: 'system',
        text: "You take the item and add it to your inventory.",
        quick_actions: []
      )
    end

    def handle_open(target_id, game_state)
      Result.success(
        entry_type: 'dm',
        text: "You open it...",
        quick_actions: []
      )
    end

    def find_npc(name, game_state)
      room = current_room(game_state)
      return nil unless room

      room.npcs.find { |n| n.name.downcase.include?(name.downcase) }
    end

    def generate_object_description(object, room)
      Result.success(
        entry_type: 'dm',
        text: object['description'] || "You see a #{object['name']}.",
        quick_actions: object_actions(object)
      )
    end

    def generate_item_description(item_id)
      Result.success(
        entry_type: 'dm',
        text: "You examine the item closely...",
        quick_actions: []
      )
    end

    def use_object(object, room)
      Result.success(
        entry_type: 'dm',
        text: "You use the #{object['name']}...",
        quick_actions: []
      )
    end

    def search_object(object, room)
      Result.success(
        entry_type: 'dm',
        text: "You search the #{object['name']}...",
        quick_actions: []
      )
    end

    def parse_description_for_clickables(text)
      clickables = []

      # Find bracketed text [like this]
      text.scan(/\[([^\]]+)\]/).each_with_index do |(match), i|
        clickable = {
          'text' => match,
          'id' => "obj_#{i}",
          'type' => determine_clickable_type(match),
          'action' => 'investigate'
        }
        clickables << clickable
      end

      { text: text, clickables: clickables }
    end

    def determine_clickable_type(text)
      text_lower = text.downcase

      if text_lower.include?('person') || text_lower.include?('figure') || text_lower.include?('man') || text_lower.include?('woman')
        'npc'
      elsif text_lower.include?('door') || text_lower.include?('path') || text_lower.include?('passage')
        'location'
      else
        'object'
      end
    end

    def generate_quick_actions(room, game_state)
      actions = []

      # Movement options
      %w[north south east west].each do |dir|
        actions << {
          label: "Go #{dir.capitalize}",
          action_type: 'move',
          params: { direction: dir }
        }
      end

      # Room-specific actions
      if room
        room.features.each do |feature|
          actions << {
            label: "Investigate #{feature['name']}",
            action_type: 'investigate',
            target_id: feature['id']
          }
        end

        room.npcs.each do |npc|
          actions << {
            label: "Talk to #{npc.name}",
            action_type: 'talk',
            target_id: npc.id.to_s
          }
        end
      end

      actions.first(8)  # Limit to 8 actions
    end

    def dialogue_actions(npc)
      [
        { label: 'Ask about rumors', action_type: 'talk', params: { topic: 'rumors' } },
        { label: 'Ask about quests', action_type: 'talk', params: { topic: 'quests' } },
        { label: 'Trade', action_type: 'talk', params: { topic: 'trade' } },
        { label: 'End conversation', action_type: 'talk', params: { topic: 'goodbye' } }
      ]
    end

    def combat_actions
      [
        { label: 'Attack', action_type: 'attack' },
        { label: 'Cast Spell', action_type: 'cast' },
        { label: 'Dodge', action_type: 'dodge' },
        { label: 'Use Item', action_type: 'use' },
        { label: 'Disengage', action_type: 'disengage' }
      ]
    end

    def object_actions(object)
      [
        { label: 'Examine', action_type: 'investigate', target_id: object['id'] },
        { label: 'Use', action_type: 'use', target_id: object['id'] },
        { label: 'Search', action_type: 'search', target_id: object['id'] }
      ]
    end

    def build_context(game_state)
      # Build context from game state, character, memories
      {}
    end

    def build_scene_context(room, game_state)
      {}
    end

    def build_scene_prompt(room, context)
      "Describe a #{room.room_type} in a dungeon. Include interesting objects and atmosphere. Mark interactive objects with [brackets]."
    end

    def build_npc_context(npc)
      {}
    end

    def system_prompt
      "You are a Dungeon Master running a D&D 5e solo adventure. Be descriptive, engaging, and fair. Mark interactive objects with [brackets like this] so players can click them."
    end

    def npc_system_prompt(npc)
      "You are #{npc.name}, an NPC in a D&D game. Personality: #{npc.personality_traits.join(', ')}. Respond in character."
    end
  end
end
