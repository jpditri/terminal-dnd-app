# frozen_string_literal: true

# Explicit requires to bypass autoloading issues
require_relative '../world_services/state_tracker'
require_relative '../world_services/faction_reputation_manager'

module AiDm
  # Orchestrates AI DM interactions with tool calling
  # Builds context, processes messages, and handles tool execution
  class Orchestrator
    attr_reader :session, :character, :ai_client

    def initialize(terminal_session)
      @session = terminal_session
      @character = session.character
      # Use Anthropic if API key is present, otherwise fall back to Ollama
      @ai_client = if ENV['ANTHROPIC_API_KEY'].present?
                     AnthropicClient.new
                   else
                     OllamaClient.new
                   end
      @decision_engine = DmDecisionEngine.new(terminal_session)
    end

    # Process player message and generate DM response with tool calls
    def process_message(message, conversation_history = [])
      # Build context for AI
      context = build_dm_context
      tools = ToolRegistry.for_claude_api

      # Generate AI response with tool use
      response = ai_client.generate_with_tools(
        prompt: message,
        context: context,
        tools: tools,
        conversation_history: conversation_history,
        max_tokens: 500,
        temperature: 0.7
      )

      # Process any tool calls
      tool_results = process_tool_calls(response[:tool_calls], conversation_history.length)

      # Generate quick actions based on context
      quick_actions = generate_quick_actions(response, tool_results)

      # Format final response
      {
        narrative: response[:text],
        tool_results: tool_results,
        pending_approvals: pending_approvals_for_session,
        quick_actions: quick_actions,
        state_updates: summarize_state_changes(tool_results)
      }
    end

    # Handle approval of pending action
    def handle_approval(action_id, approved:, reason: nil, reviewer:)
      action = DmPendingAction.find(action_id)

      if approved
        result = action.approve!(reviewer: reviewer)

        # Generate AI follow-up based on result
        if result[:success]
          follow_up = generate_approval_follow_up(action, result)
          { result: result, follow_up: follow_up }
        else
          { result: result, error: result[:error] }
        end
      else
        action.reject!(reason: reason)
        follow_up = generate_rejection_response(action, reason)
        { rejected: true, follow_up: follow_up }
      end
    end

    # Batch approve multiple pending actions
    def batch_approve(action_ids, reviewer:)
      results = []

      DmPendingAction.where(id: action_ids).order(:batch_order).each do |action|
        result = action.approve!(reviewer: reviewer)
        results << { action_id: action.id, result: result }
        break unless result[:success]
      end

      {
        results: results,
        all_success: results.all? { |r| r[:result][:success] }
      }
    end

    # Generate DM response without tool calls (for simpler interactions)
    def generate_narrative(prompt, context_type: :exploration)
      context = build_narrative_context(context_type)

      response = ai_client.generate(
        prompt: prompt,
        system: context,
        max_tokens: 1000,
        temperature: 0.8
      )

      response[:content]
    end

    # Get NPC spawn recommendation from decision engine
    def get_npc_spawn_recommendation(context = {})
      @decision_engine.generate_spawn_recommendation(context)
    end

    # Check if NPC should be spawned
    def should_spawn_npc?(context = {})
      @decision_engine.should_spawn_npc?(context)
    end

    private

    def process_tool_calls(tool_calls, conversation_turn)
      return [] if tool_calls.blank?

      executor = ToolExecutor.new(session, character)
      results = []

      tool_calls.each do |tool_call|
        result = executor.execute(
          tool_call[:name],
          tool_call[:parameters].deep_symbolize_keys,
          {
            reasoning: tool_call[:reasoning],
            conversation_turn: conversation_turn
          }
        )
        results << result.merge(tool_name: tool_call[:name])
      end

      results
    end

    def build_dm_context
      [
        dm_persona,
        room_context,
        character_context,
        game_state_context,
        quest_consequence_context,
        content_pacing_context,
        player_intent_context,
        faction_context,
        narrative_arc_context,
        combat_context,
        recent_history_context,
        tool_usage_guidance
      ].compact.join("\n\n")
    end

    def dm_persona
      base_persona = <<~PERSONA
        You are a skilled Dungeon Master running a D&D 5th Edition game.
        Your role is to create an immersive, collaborative storytelling experience.

        CORE PRINCIPLES:
        - **NARRATIVE FIRST**: Always describe the scene, NPCs, atmosphere. Don't just prompt for actions.
        - **BE CREATIVE**: Describe taverns, forests, dungeons, NPCs with personality and detail
        - **SHOW, DON'T TELL**: Paint vivid pictures with your descriptions
        - **REACT TO PLAYER INTENT**: Respond to what the player is trying to do, not just mechanics
        - **BALANCE FREEDOM & STRUCTURE**: Let players explore, but provide clear story hooks
        - **USE RICH DESCRIPTIONS**: Sights, sounds, smells, textures - make the world feel real

        TOOL USAGE:
        - Use tools ONLY when game state must change (HP, inventory, combat)
        - NEVER use tools for simple conversations or exploration
        - When the player talks to NPCs, exploring, or asking questions - just narrate, don't use tools
        - Tools are for mechanics, not storytelling

        FORMATTING YOUR RESPONSES:
        Your narrative will be rendered as markdown. Use formatting to enhance readability:
        - Use **bold** for emphasis, important NPCs, or dramatic moments
        - Use *italics* for inner thoughts, whispers, or atmospheric descriptions
        - Use line breaks to separate paragraphs and improve readability
        - Use > blockquotes for ancient text, prophecies, or special messages
        - Use --- for scene transitions or significant time passages
        - Use lists (- or 1.) when presenting multiple options or items
        - Use `code formatting` for game mechanics terms (DC, AC, HP, etc.)

        Examples:
        - "The **ancient door** creaks open. *Dust motes dance in shafts of golden light.* Before you lies a chamber untouched for centuries..."
        - "The bartender, a gruff half-orc named **Grag**, eyes you suspiciously. 'We don't get many strangers here,' he rumbles."
      PERSONA

      # Add specific guidance based on whether character exists
      if character.nil?
        base_persona + <<~NO_CHAR

          NO CHARACTER YET:
          The player hasn't created a character. Your responses should:
          - Welcome them to the game
          - Offer to help them create a character
          - Describe the world they're about to enter
          - Ask what kind of hero they'd like to be
          - NEVER suggest combat, exploration, or character-specific actions
          - Focus on character creation and world-building
          - Be encouraging and helpful, not pushy

          Example: "Welcome, traveler! I'm excited to embark on this adventure with you. Before we begin, let's bring your hero to life. What kind of character would you like to play? A brave warrior? A cunning rogue? Or perhaps a wise wizard? Tell me about the hero you imagine, and I'll help you create them."
        NO_CHAR
      else
        base_persona
      end
    end

    def room_context
      room_manager = session.room_manager
      current_room = room_manager.current_room

      <<~CONTEXT
        CURRENT ROOM/CONTEXT:
        You are currently in: **#{current_room[:name]}**
        #{current_room[:description]}

        DM GUIDANCE FOR THIS ROOM:
        #{current_room[:dm_guidance]}

        CHARACTER EDITABILITY:
        #{session.character_locked ? '🔒 Character is LOCKED for gameplay. Only suggest edits via approval tools.' : '✏️ Character can be freely edited.'}

        #{session.in_game_room? ? 'The game has started. Focus on storytelling and adventure!' : 'Still in setup/preparation. Help the player get ready.'}
      CONTEXT
    end

    def character_context
      return nil unless character

      <<~CONTEXT
        CURRENT CHARACTER:
        - Name: #{character.name}
        - Race: #{character.race&.name || 'Unknown'}
        - Class: #{character.character_class&.name || 'Unknown'} (Level #{character.level})
        - HP: #{character.hit_points_current}/#{character.hit_points_max}
        - AC: #{character.calculated_armor_class rescue 10}
        - Ability Scores:
          STR #{character.strength} (#{format_modifier(character.strength_modifier)})
          DEX #{character.dexterity} (#{format_modifier(character.dexterity_modifier)})
          CON #{character.constitution} (#{format_modifier(character.constitution_modifier)})
          INT #{character.intelligence} (#{format_modifier(character.intelligence_modifier)})
          WIS #{character.wisdom} (#{format_modifier(character.wisdom_modifier)})
          CHA #{character.charisma} (#{format_modifier(character.charisma_modifier)})
        - Gold: #{character.gold || 0}
        - XP: #{character.experience || 0}
        #{conditions_text}
        #{inventory_context}
        #{spell_manager_context}
      CONTEXT
    end

    def conditions_text
      tracker = character&.character_combat_tracker
      return '' unless tracker

      conditions = tracker.active_conditions
      return '' if conditions.empty?

      "- Conditions: #{conditions.map { |c| c['name'] }.join(', ')}"
    end

    def game_state_context
      pending_count = DmPendingAction.where(terminal_session: session).pending.count
      quest_count = character ? QuestLog.where(character: character, status: 'active').count : 0

      <<~STATE
        SESSION STATE:
        - Mode: #{session.mode || 'exploration'}
        - Active Quests: #{quest_count}
        - Pending Approvals: #{pending_count}
      STATE
    end

    def quest_consequence_context
      return nil unless session.campaign

      quests_with_context = QuestLog
        .where(campaign: session.campaign)
        .where(status: %w[active available])
        .where('presentation_count > 0 OR consequence_applied = true OR resolution_type IS NOT NULL')
        .map do |quest|
          manager = Quest::ConsequenceManager.new(quest)
          context_msg = manager.context_message
          next nil if context_msg.blank?

          "- #{quest.title}: #{context_msg}"
        end.compact

      return nil if quests_with_context.empty?

      <<~QUEST_CONTEXT
        QUEST CONSEQUENCES & STATE:
        Important: These quests have been offered to the player or have evolved. Acknowledge their state naturally.
        #{quests_with_context.join("\n")}

        Guidelines for quest presentation:
        - Don't spam quests that have been ignored multiple times
        - Acknowledge consequences when they've been applied
        - Respect player agency - if they ignore a quest, let it evolve or resolve
        - Quests that auto-resolved can be mentioned as past events
      QUEST_CONTEXT
    end

    def content_pacing_context
      analyzer = Content::PacingAnalyzer.new(session)
      pacing_message = analyzer.dm_context_message

      return nil if pacing_message.blank?

      <<~PACING
        CONTENT PACING:
        #{pacing_message}

        Pacing Guidelines:
        - Vary content types to prevent player fatigue
        - If warned about excessive combat, focus on social/exploration
        - If warned about excessive social, consider combat or discovery
        - Balance is key - don't overwhelm with any single content type
      PACING
    end

    def player_intent_context
      analyzer = Player::IntentAnalyzer.new(session)
      intent_message = analyzer.dm_context_message

      return nil if intent_message.blank?

      analysis = analyzer.analyze
      style_recs = analyzer.style_recommendations

      <<~INTENT
        PLAYER PLAYSTYLE:
        #{intent_message}

        Style Recommendations:
        #{style_recs.map { |rec| "- #{rec}" }.join("\n")}

        Adapt your DM style to match the player's preferences and engagement level.
      INTENT
    end

    def faction_context
      return nil unless session.campaign && character

      reputation_manager = WorldServices::FactionReputationManager.new(session.campaign)
      faction_message = reputation_manager.dm_context_message(character)
      summary = reputation_manager.faction_attitudes_summary(character)

      return nil if faction_message.blank? && summary.blank?

      context_parts = []
      context_parts << faction_message if faction_message.present?
      context_parts << summary if summary.present?

      return nil if context_parts.empty?

      <<~FACTION
        FACTION RELATIONSHIPS:
        #{context_parts.join("\n\n")}

        Consider faction attitudes when spawning NPCs, creating encounters, and narrating events.
        Use adjust_faction_reputation tool when character actions affect faction standing.
      FACTION
    end

    def narrative_arc_context
      return nil unless session.campaign

      arc_tracker = Narrative::ArcTracker.new(session.campaign)
      arc_message = arc_tracker.dm_context_message

      return nil if arc_message.blank?

      recommendations = arc_tracker.generate_recommendations

      context = arc_message.dup
      if recommendations.any?
        context += "\n\nNarrative Recommendations:\n"
        context += recommendations.first(3).map { |rec| "- #{rec}" }.join("\n")
      end

      context
    end

    def combat_context
      return nil unless in_combat?

      combat = find_active_combat
      return nil unless combat

      manager = SoloPlay::CombatManager.new(combat)
      state = manager.get_combat_state

      participants_text = state[:participants].map do |p|
        "  - #{p[:name]}: #{p[:current_hp]}/#{p[:max_hp]} HP, AC #{p[:armor_class]}#{p[:is_dead] ? ' (DEAD)' : ''}"
      end.join("\n")

      <<~COMBAT
        COMBAT ACTIVE:
        - Round: #{state[:round]}, Turn: #{state[:turn]}
        - Current: #{state[:current_participant]}
        - Participants:
        #{participants_text}
      COMBAT
    end

    def recent_history_context
      recent_actions = DmActionAuditLog
        .where(terminal_session: session)
        .where(execution_status: 'executed')
        .order(created_at: :desc)
        .limit(10)
        .map { |log| "- #{log.tool_name}: #{log.result['message']}" }
        .reverse
        .join("\n")

      return nil if recent_actions.blank?

      "RECENT ACTIONS:\n#{recent_actions}"
    end

    def tool_usage_guidance
      <<~GUIDANCE
        TOOL USAGE:
        - Use tools to make actual changes to game state
        - Prefer immediate tools for minor adjustments (granting items, rolling dice)
        - Queue significant changes for approval (ability scores, level ups, backstory modifications)
        - Always provide reasoning for tool calls
        - You can call multiple tools in sequence
        - If a tool fails, acknowledge it narratively and suggest alternatives
        - For combat, use the combat tools (apply_damage, use_action, next_turn)
        - For skill checks, use roll_dice with appropriate DC
      GUIDANCE
    end

    def build_narrative_context(context_type)
      case context_type
      when :combat
        [dm_persona, character_context, combat_context].compact.join("\n\n")
      when :dialogue
        [dm_persona, character_context, "Focus on NPC dialogue and social interaction."].join("\n\n")
      else
        [dm_persona, character_context, game_state_context].compact.join("\n\n")
      end
    end

    def generate_quick_actions(response, tool_results)
      actions = []
      narrative = response[:text] || ''

      # Check if character exists - if not, only offer character creation
      unless session.character.present?
        return [
          { label: 'Create character', action: 'create_character', icon: 'plus' },
          { label: 'Help', action: 'help', icon: 'help' }
        ]
      end

      # Context-aware quick actions based on mode
      case session.mode
      when 'exploration'
        actions += [
          { label: 'Look around', action: 'search', icon: 'eye' },
          { label: 'Check inventory', action: 'inventory', icon: 'backpack' }
        ]
      when 'combat'
        actions += [
          { label: 'Attack', action: 'attack', icon: 'sword' },
          { label: 'End Turn', action: 'end_turn', icon: 'clock' }
        ]
      when 'dialogue'
        actions += [
          { label: 'Ask questions', action: 'talk', params: { topic: 'general' }, icon: 'chat' },
          { label: 'Persuade', action: 'persuade', icon: 'heart' }
        ]
      end

      # Add actions based on narrative content
      if narrative.match?(/attack|enemy|hostile|combat/i) && session.mode != 'combat'
        actions << { label: 'Roll Initiative', action: 'roll', params: { dice: '1d20' }, icon: 'dice' }
      end

      if narrative.match?(/says|asks|greets|npc/i)
        actions << { label: 'Talk', action: 'talk', icon: 'chat' }
      end

      if narrative.match?(/door|chest|container|lock/i)
        actions << { label: 'Investigate', action: 'investigate', icon: 'search' }
      end

      # Check for pending approvals
      if tool_results.any? { |r| r[:queued] }
        actions.unshift({ label: 'Review Pending', action: 'review_pending', icon: 'alert', priority: true })
      end

      actions.first(6)
    end

    def pending_approvals_for_session
      DmPendingAction
        .where(terminal_session: session)
        .pending
        .map do |action|
          {
            id: action.id,
            tool_name: action.tool_name,
            description: action.description,
            dm_reasoning: action.dm_reasoning,
            expires_at: action.expires_at&.iso8601,
            time_remaining: action.time_remaining
          }
        end
    end

    def summarize_state_changes(tool_results)
      tool_results
        .select { |r| r[:success] && !r[:queued] }
        .map { |r| { tool: r[:tool_name], change: r[:message] } }
    end

    def generate_approval_follow_up(action, result)
      case action.tool_name
      when 'set_ability_score'
        "Your #{action.parameters['ability']} has been set to #{action.parameters['value']}. #{result[:message]}"
      when 'level_up'
        "Congratulations! You've leveled up. #{result[:message]}"
      when 'modify_backstory'
        "Your backstory has been updated. This new chapter of your history is now part of who you are."
      when 'rewind_turn'
        "Time seems to shift... #{result[:message]} What would you like to do differently?"
      else
        "The requested #{action.tool_name.humanize.downcase} has been applied. #{result[:message]}"
      end
    end

    def generate_rejection_response(action, reason)
      base = "Understood - I won't #{action.tool_name.humanize.downcase}."
      base += " #{reason}" if reason.present?
      base += " How would you like to proceed instead?"
      base
    end

    def in_combat?
      find_active_combat.present?
    end

    def find_active_combat
      return nil unless character

      Combat.where(status: 'active')
            .joins(:combat_participants)
            .where(combat_participants: { character_id: character.id })
            .first
    end

    def format_modifier(ability_score)
      return '+0' unless ability_score

      modifier = ((ability_score - 10) / 2).floor
      modifier >= 0 ? "+#{modifier}" : modifier.to_s
    end

    # Inventory context for AI DM awareness
    def inventory_context
      return '' unless character

      inventory = character.character_inventory
      return '' unless inventory

      context_parts = []
      context_parts << "INVENTORY:"

      # Currency
      total_gold = inventory.total_wealth_in_gp
      context_parts << "- Total Wealth: #{total_gold} gp"

      # Encumbrance
      encumbrance = inventory.encumbrance_status
      if encumbrance.to_s != 'normal'
        context_parts << "- Encumbrance: #{encumbrance.to_s.titleize} (#{inventory.current_weight}/#{inventory.carry_capacity} lbs)"
      end

      # Equipped items (summary)
      equipped_items = inventory.equipped_items || {}
      if equipped_items.any?
        equipped_names = equipped_items.values.map { |item_data| item_data[:name] }.compact
        context_parts << "- Equipped: #{equipped_names.join(', ')}"
      end

      # Attuned items
      attuned_items = inventory.attuned_items || []
      if attuned_items.any?
        context_parts << "- Attuned Items: #{attuned_items.length}/3"
      end

      # Important items (magic items, quest items)
      inventory_items = inventory.inventory_items || []
      magic_items = inventory_items.select { |item_data| item_data[:item]&.magic == true }
      if magic_items.any? && magic_items.length <= 5
        magic_names = magic_items.map { |item_data| item_data[:item]&.name }.compact
        context_parts << "- Magic Items: #{magic_names.join(', ')}"
      elsif magic_items.any?
        context_parts << "- Magic Items: #{magic_items.length} items"
      end

      "\n" + context_parts.join("\n")
    end

    # Spell manager context for AI DM awareness
    def spell_manager_context
      return '' unless character

      spell_manager = character.character_spell_manager
      return '' unless spell_manager

      context_parts = []
      context_parts << "SPELLCASTING:"

      # Spellcasting ability
      ability = spell_manager.spellcasting_ability
      context_parts << "- Ability: #{ability&.titleize}"

      # Spell slots
      spell_slots = spell_manager.spell_slots || {}
      available_slots = spell_slots.select { |level, count| count.to_i > 0 && level.to_i > 0 }

      if available_slots.any?
        slots_summary = available_slots.map do |level, count|
          "#{level.ordinalize}(#{count})"
        end.join(', ')
        context_parts << "- Available Slots: #{slots_summary}"
      end

      # Cantrips
      cantrips_known = spell_manager.cantrips_known || 0
      if cantrips_known > 0
        context_parts << "- Cantrips Known: #{cantrips_known}"
      end

      # Concentration
      concentration = spell_manager.concentration
      if concentration && concentration['spell_id']
        active_spell = Spell.find_by(id: concentration['spell_id'])
        if active_spell
          context_parts << "- Concentration: #{active_spell.name} (DC #{concentration['save_dc'] || 10})"
        end
      end

      # Prepared spells count (if applicable)
      prepared_spells = spell_manager.prepared_spells || []
      if prepared_spells.any?
        context_parts << "- Prepared Spells: #{prepared_spells.length}"
      end

      "\n" + context_parts.join("\n")
    end
  end
end
