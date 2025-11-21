# frozen_string_literal: true

module AiDm
  # Executes AI DM tools, delegating to existing services
  # Handles state capture for audit trail and rewind capability
  class ToolExecutor
    attr_reader :session, :character, :errors

    def initialize(terminal_session, character = nil)
      @session = terminal_session
      @character = character || terminal_session.character
      @errors = []
    end

    # Execute a tool immediately or queue for approval
    def execute(tool_name, parameters, options = {})
      tool_config = ToolRegistry.get(tool_name)
      return error_result("Unknown tool: #{tool_name}") unless tool_config

      # Validate parameters
      validation = validate_parameters(tool_config, parameters)
      return error_result(validation[:error]) unless validation[:valid]

      # Check character lock for character-modifying tools
      if character_locked_for_tool?(tool_name) && !options[:force]
        return error_result("Character is locked. Use approval system to request changes.")
      end

      # Check if approval required
      if tool_config[:approval_required] && !options[:skip_approval]
        queue_for_approval(tool_name, parameters, options)
      else
        execute_immediately(tool_name, parameters, options)
      end
    end

    # Execute multiple tools as a batch
    def execute_batch(tools, options = {})
      batch_id = SecureRandom.uuid
      results = []

      tools.each_with_index do |tool_call, index|
        result = execute(
          tool_call[:tool],
          tool_call[:parameters],
          options.merge(batch_id: batch_id, batch_order: index)
        )
        results << result

        # Stop batch if critical failure
        break if result[:critical_failure]
      end

      {
        batch_id: batch_id,
        results: results,
        all_success: results.all? { |r| r[:success] }
      }
    end

    private

    def execute_immediately(tool_name, parameters, options)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      state_before = capture_state

      result = ApplicationRecord.transaction do
        case tool_name.to_sym
        # Character Management
        when :create_character then create_character(parameters)
        when :set_ability_score then set_ability_score(parameters)
        when :grant_item then grant_item(parameters)
        when :grant_skill_proficiency then grant_skill_proficiency(parameters)
        when :modify_backstory then modify_backstory(parameters)
        when :level_up then level_up(parameters)

        # Combat - delegates to existing services
        when :start_combat then start_combat(parameters)
        when :next_turn then next_turn(parameters)
        when :use_action then use_action(parameters)
        when :use_bonus_action then use_bonus_action(parameters)
        when :use_reaction then use_reaction(parameters)
        when :use_movement then use_movement(parameters)
        when :apply_damage then apply_damage(parameters)
        when :apply_healing then apply_healing(parameters)
        when :roll_initiative then roll_initiative(parameters)
        when :end_combat then end_combat(parameters)

        # Conditions
        when :apply_condition then apply_condition(parameters)
        when :remove_condition then remove_condition(parameters)
        when :apply_exhaustion then apply_exhaustion(parameters)
        when :death_save then death_save(parameters)

        # Economy
        when :grant_gold then grant_gold(parameters)
        when :grant_experience then grant_experience(parameters)

        # Quests
        when :create_quest then create_quest(parameters)
        when :present_quest then present_quest(parameters)
        when :accept_quest then accept_quest(parameters)
        when :complete_objective then complete_objective(parameters)

        # World
        when :spawn_npc then spawn_npc(parameters)

        # NPC Dialogue
        when :npc_speak then npc_speak(parameters)
        when :npc_react then npc_react(parameters)

        # Factions
        when :create_faction then create_faction(parameters)
        when :adjust_faction_reputation then adjust_faction_reputation(parameters)

        # Game State
        when :roll_dice then roll_dice(parameters)
        when :validate_action then validate_action(parameters)
        when :explain_rule then explain_rule(parameters)
        when :rewind_turn then rewind_turn(parameters)
        when :adjust_hp then adjust_hp(parameters)
        when :short_rest then short_rest(parameters)
        when :long_rest then long_rest(parameters)

        # Homebrew & Treasure
        when :create_homebrew_item then create_homebrew_item(parameters)
        when :generate_treasure then generate_treasure(parameters)
        when :create_loot_table then create_loot_table(parameters)
        when :grant_homebrew_item then grant_homebrew_item(parameters)
        when :attune_item then attune_item(parameters)
        when :identify_item then identify_item(parameters)
        when :remove_item then remove_item(parameters)
        when :create_homebrew_spell then create_homebrew_spell(parameters)
        when :list_homebrew then list_homebrew(parameters)

        else
          error_result("Tool not implemented: #{tool_name}")
        end
      end

      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      execution_time_ms = ((end_time - start_time) * 1000).to_i

      state_after = capture_state

      # Create audit log
      DmActionAuditLog.create!(
        terminal_session: session,
        character: character,
        tool_name: tool_name,
        parameters: parameters,
        result: result,
        state_before: state_before,
        state_after: state_after,
        execution_status: result[:success] ? 'executed' : 'failed',
        trigger_source: options[:trigger_source] || 'ai',
        conversation_turn: options[:conversation_turn],
        execution_time_ms: execution_time_ms
      )

      # Broadcast update
      broadcast_state_change(tool_name, result) if result[:success]

      # Add suggestions for next actions
      enrich_with_suggestions(tool_name, result) if result[:success]

      result
    rescue StandardError => e
      Rails.logger.error("Tool execution failed: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      error_result(e.message)
    end

    def queue_for_approval(tool_name, parameters, options)
      pending_action = DmPendingAction.create!(
        terminal_session: session,
        character: character,
        user: session.user,
        tool_name: tool_name,
        parameters: parameters,
        status: 'pending',
        dm_reasoning: options[:reasoning],
        batch_id: options[:batch_id],
        batch_order: options[:batch_order]
      )

      # Broadcast pending action to player
      broadcast_pending_action(pending_action)

      {
        success: true,
        queued: true,
        action_id: pending_action.id,
        message: "Action queued for approval: #{pending_action.description}",
        tool_name: tool_name
      }
    end

    # ========================================
    # CHARACTER MANAGEMENT TOOLS
    # ========================================

    def create_character(params)
      # Use defaults if not specified
      race_name = params[:race] || 'Human'
      class_name = params[:character_class] || 'Fighter'

      race = Race.find_by(name: race_name) || Race.first
      char_class = CharacterClass.find_by(name: class_name) || CharacterClass.first
      background = Background.find_by(name: params[:background]) if params[:background]

      return error_result('No races found in database') unless race
      return error_result('No character classes found in database') unless char_class

      # Standard array for ability scores if not provided
      character = Character.create!(
        user: session.user,
        campaign: session.campaign,
        name: params[:name] || 'Adventurer',
        race: race,
        character_class: char_class,
        background: background,
        level: 1,
        strength: params.dig(:ability_scores, :strength) || 15,
        dexterity: params.dig(:ability_scores, :dexterity) || 14,
        constitution: params.dig(:ability_scores, :constitution) || 13,
        intelligence: params.dig(:ability_scores, :intelligence) || 12,
        wisdom: params.dig(:ability_scores, :wisdom) || 10,
        charisma: params.dig(:ability_scores, :charisma) || 8
      )

      # Calculate initial HP
      die_size = char_class.hit_die&.gsub(/\D/, '')&.to_i || 8
      character.update!(
        hit_points_max: die_size + character.constitution_modifier,
        hit_points_current: die_size + character.constitution_modifier
      )

      # Update session
      session.update!(character: character)
      @character = character

      success_result("Created #{race.name} #{char_class.name}: #{character.name}", character: character_summary)
    end

    def set_ability_score(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      ability = params[:ability].to_sym
      old_value = char.send(ability)

      char.update!(ability => params[:value])

      # Recalculate derived values for constitution
      if ability == :constitution
        hp_diff = (char.constitution_modifier - ((old_value - 10) / 2)) * char.level
        char.update!(
          hit_points_max: char.hit_points_max + hp_diff,
          hit_points_current: [char.hit_points_current + hp_diff, char.hit_points_max + hp_diff].min
        )
      end

      success_result(
        "Set #{ability} from #{old_value} to #{params[:value]}",
        ability: ability,
        old_value: old_value,
        new_value: params[:value]
      )
    end

    def grant_item(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      item = Item.find_or_create_by!(name: params[:item_name]) do |i|
        i.item_type = params.dig(:properties, :type) || 'misc'
        i.weight = params.dig(:properties, :weight) || 0
        i.value = params.dig(:properties, :value) || 0
      end

      char_item = CharacterItem.create!(
        character: char,
        item: item,
        quantity: params[:quantity] || 1,
        equipped: params[:equipped] || false
      )

      success_result(
        "Granted #{params[:quantity] || 1}x #{item.name}",
        item_id: item.id,
        character_item_id: char_item.id
      )
    end

    def grant_skill_proficiency(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      skills = char.skills || {}
      skill_name = params[:skill].to_s

      skills[skill_name] ||= {}
      skills[skill_name]['proficient'] = true
      skills[skill_name]['expertise'] = params[:expertise] if params[:expertise]

      char.update!(skills: skills)

      success_result(
        "Granted #{params[:expertise] ? 'expertise' : 'proficiency'} in #{skill_name}",
        skill: skill_name,
        expertise: params[:expertise]
      )
    end

    def modify_backstory(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      if params[:append]
        char.backstory = "#{char.backstory}\n\n#{params[:new_backstory]}"
      else
        char.backstory = params[:new_backstory]
      end
      char.save!

      success_result('Updated backstory')
    end

    def level_up(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      # Use existing LevelUpService if available
      if defined?(CharacterServices::LevelUpService)
        service = CharacterServices::LevelUpService.new(char)
        result = service.execute(
          options: {
            hp_choice: params[:hp_choice],
            skip_xp_check: params[:skip_xp_check]
          }
        )
        return result[:success] ? success_result(result[:message], new_level: char.level) : error_result(result[:message])
      end

      # Fallback implementation
      old_level = char.level
      char.update!(level: old_level + 1)

      success_result("Leveled up to #{char.level}", old_level: old_level, new_level: char.level)
    end

    # ========================================
    # COMBAT TOOLS - Delegating to existing services
    # ========================================

    def start_combat(params)
      # Check if character exists
      return error_result('Character must exist before starting combat') unless character.present?

      # Delegate to CombatInitiator
      if defined?(SoloPlay::CombatInitiator) && session.respond_to?(:solo_sessions)
        solo_session = session.solo_sessions.last || session
        initiator = SoloPlay::CombatInitiator.new(solo_session)
        result = initiator.initiate_combat(params[:enemies])
        return success_result('Combat initiated', combat_id: result[:combat_id], participants: result[:participants])
      end

      # Fallback - combat system not available
      error_result('Combat system not available')
    end

    def next_turn(_params)
      combat = find_active_combat
      return error_result('No active combat') unless combat

      manager = SoloPlay::CombatManager.new(combat)
      result = manager.next_turn!

      success_result(
        "Advanced to turn #{result[:turn]} of round #{result[:round]}",
        round: result[:round],
        turn: result[:turn],
        new_round: result[:new_round],
        current_participant: result[:current_participant]
      )
    end

    def use_action(params)
      tracker = character_combat_tracker
      return error_result('No combat tracker') unless tracker

      if tracker.use_action
        success_result("Action used: #{params[:action_type]}")
      else
        error_result('Action already used this turn')
      end
    end

    def use_bonus_action(_params)
      tracker = character_combat_tracker
      return error_result('No combat tracker') unless tracker

      if tracker.use_bonus_action
        success_result('Bonus action used')
      else
        error_result('Bonus action already used this turn')
      end
    end

    def use_reaction(_params)
      tracker = character_combat_tracker
      return error_result('No combat tracker') unless tracker

      if tracker.use_reaction
        success_result('Reaction used')
      else
        error_result('Reaction already used this round')
      end
    end

    def use_movement(params)
      tracker = character_combat_tracker
      return error_result('No combat tracker') unless tracker

      if tracker.use_movement(params[:feet])
        success_result(
          "Moved #{params[:feet]} feet",
          feet_moved: params[:feet],
          remaining: tracker.remaining_movement
        )
      else
        error_result("Cannot move #{params[:feet]} feet - only #{tracker.remaining_movement} remaining")
      end
    end

    def apply_damage(params)
      combat = find_active_combat
      return error_result('No active combat') unless combat

      manager = SoloPlay::CombatManager.new(combat)
      result = manager.apply_damage(params[:participant_id], params[:amount])

      # Check combat end conditions
      end_check = manager.check_combat_end_condition

      success_result(
        "#{params[:reason]}: #{params[:amount]} #{params[:damage_type] || 'damage'}",
        participant_id: result[:participant_id],
        current_hp: result[:current_hp],
        max_hp: result[:max_hp],
        is_dead: result[:is_dead],
        combat_over: end_check[:combat_over],
        outcome: end_check[:outcome]
      )
    end

    def apply_healing(params)
      combat = find_active_combat
      return error_result('No active combat') unless combat

      manager = SoloPlay::CombatManager.new(combat)
      result = manager.apply_healing(params[:participant_id], params[:amount])

      success_result(
        "#{params[:reason]}: +#{params[:amount]} HP",
        participant_id: result[:participant_id],
        current_hp: result[:current_hp],
        max_hp: result[:max_hp]
      )
    end

    def roll_initiative(params)
      tracker = character_combat_tracker
      return error_result('No combat tracker') unless tracker

      result = if params[:advantage]
        tracker.roll_initiative_advantage
      elsif params[:disadvantage]
        tracker.roll_initiative_disadvantage
      else
        tracker.roll_initiative
      end

      success_result(
        "Rolled initiative: #{result[:total]}",
        roll: result[:roll],
        modifier: result[:modifier],
        total: result[:total],
        natural: result[:natural]
      )
    end

    def end_combat(params)
      combat = find_active_combat
      return error_result('No active combat') unless combat

      manager = SoloPlay::CombatManager.new(combat)
      result = manager.end_combat!

      # Automatic treasure generation on victory
      treasure_result = nil
      if params[:outcome] == 'victory'
        treasure_result = generate_combat_treasure(combat)
      end

      response_data = {
        combat_id: result[:combat_id],
        final_round: result[:final_round]
      }
      response_data[:treasure] = treasure_result if treasure_result

      success_result(
        "Combat ended: #{params[:outcome] || 'concluded'}",
        **response_data
      )
    end

    # ========================================
    # CONDITIONS TOOLS
    # ========================================

    def apply_condition(params)
      tracker = character_combat_tracker(params[:character_id])
      return error_result('No combat tracker') unless tracker

      if tracker.apply_condition(params[:condition], duration: params[:duration], source: params[:source])
        success_result(
          "Applied condition: #{params[:condition]}",
          condition: params[:condition],
          duration: params[:duration]
        )
      else
        error_result("Condition #{params[:condition]} already applied")
      end
    end

    def remove_condition(params)
      tracker = character_combat_tracker(params[:character_id])
      return error_result('No combat tracker') unless tracker

      tracker.remove_condition(params[:condition])
      success_result("Removed condition: #{params[:condition]}")
    end

    def apply_exhaustion(params)
      tracker = character_combat_tracker(params[:character_id])
      return error_result('No combat tracker') unless tracker

      old_level = tracker.exhaustion_level
      new_level = [old_level + params[:levels], 0].max
      new_level = [new_level, 6].min

      tracker.update!(exhaustion_level: new_level)

      success_result(
        "#{params[:reason]}: Exhaustion #{old_level} -> #{new_level}",
        old_level: old_level,
        new_level: new_level
      )
    end

    def death_save(params)
      tracker = character_combat_tracker(params[:character_id])
      return error_result('No combat tracker') unless tracker

      result = tracker.roll_death_save(
        advantage: params[:advantage],
        disadvantage: params[:disadvantage]
      )

      return error_result(result[:error]) if result[:error]

      success_result(
        "Death save: #{result[:result]}",
        roll: result[:roll],
        result: result[:result],
        successes: result[:successes],
        failures: result[:failures]
      )
    end

    # ========================================
    # ECONOMY TOOLS
    # ========================================

    def grant_gold(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      old_gold = char.gold || 0
      char.update!(gold: old_gold + params[:amount])

      success_result(
        "#{params[:reason]}: #{params[:amount] >= 0 ? '+' : ''}#{params[:amount]} gold",
        old_gold: old_gold,
        new_gold: char.gold
      )
    end

    def grant_experience(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      old_xp = char.experience || 0
      char.update!(experience: old_xp + params[:amount])

      success_result(
        "#{params[:reason]}: +#{params[:amount]} XP",
        old_xp: old_xp,
        new_xp: char.experience
      )
    end

    # ========================================
    # QUEST TOOLS
    # ========================================

    def create_quest(params)
      quest = QuestLog.create!(
        character: character,
        campaign: session.campaign,
        title: params[:title],
        description: params[:description],
        status: params[:status] || 'available', # Default to 'available' to track offers
        difficulty: params[:difficulty] || 'medium',
        gold_reward: params[:gold_reward] || 0,
        experience_reward: params[:experience_reward] || 0,
        item_rewards: params[:item_rewards] || [],
        started_at: params[:status] == 'active' ? Time.current : nil
      )

      params[:objectives]&.each_with_index do |obj, i|
        quest.quest_objectives.create!(
          description: obj[:description],
          order_index: i,
          progress_target: obj[:target] || 1
        )
      end

      # Record quest presentation if being offered to player
      if params[:presenting] || params[:status] == 'available'
        Quest::ConsequenceManager.new(quest).record_presentation
      end

      success_result("Created quest: #{quest.title}", quest_id: quest.id)
    end

    # Present an existing quest to the player via NPC
    def present_quest(params)
      quest_id = params[:quest_id]
      return error_result('Quest ID required') unless quest_id

      quest = QuestLog.find(quest_id)
      manager = Quest::ConsequenceManager.new(quest)

      # Check if quest should be presented
      unless manager.should_present_again?
        return error_result(
          "Quest '#{quest.title}' has been offered too many times and should not be presented again. " \
          "Consider letting it auto-resolve or present different content."
        )
      end

      # Record presentation
      manager.record_presentation

      # Get context message for AI awareness
      context = manager.context_message

      success_result(
        "Presented quest '#{quest.title}' to player. #{context}",
        quest_id: quest.id,
        presentation_count: quest.presentation_count,
        should_track_response: true
      )
    end

    # Accept a quest (player agrees to undertake it)
    def accept_quest(params)
      quest_id = params[:quest_id]
      return error_result('Quest ID required') unless quest_id

      quest = QuestLog.find(quest_id)
      quest.update!(status: 'active', started_at: Time.current)

      success_result("Quest '#{quest.title}' accepted and is now active", quest_id: quest.id)
    end

    def complete_objective(params)
      quest = QuestLog.find(params[:quest_id])
      objective = quest.quest_objectives.find(params[:objective_id])

      if params[:partial_progress]
        objective.update!(progress_current: params[:partial_progress])
        objective.update!(completed: true) if objective.progress_current >= objective.progress_target
      else
        objective.update!(completed: true)
      end

      # Check if quest is complete
      quest_complete = false
      if quest.quest_objectives.all?(&:completed)
        quest.update!(status: 'completed', completed_at: Time.current)
        quest_complete = true

        # Grant rewards
        if character
          character.update!(
            gold: (character.gold || 0) + quest.gold_reward,
            experience: (character.experience || 0) + quest.experience_reward
          )
        end
      end

      success_result(
        "Completed objective: #{objective.description}",
        quest_complete: quest_complete
      )
    end

    # ========================================
    # WORLD TOOLS
    # ========================================

    def spawn_npc(params)
      return error_result('Campaign required for NPC spawning') unless session.campaign

      spawner = SoloPlay::NpcSpawner.new(session.campaign)

      # Determine which spawn method to use based on parameters
      npc = if params[:role] && params[:name]
        # Named narrative NPC
        spawner.spawn_for_narrative(
          role: params[:role],
          name: params[:name],
          description: params[:description] || "A #{params[:role]}",
          importance: params[:importance] || 'minor'
        )
      elsif params[:encounter_type]
        # Random encounter NPC
        spawner.spawn_for_random_encounter(
          encounter_type: params[:encounter_type],
          terrain: params[:location] || 'road',
          character_level: character&.level || 1
        )
      elsif params[:location]
        # Scene-based NPC
        spawner.spawn_for_scene_entry(
          scene: params[:scene] || 'entering location',
          environment: params[:location],
          character_level: character&.level || 1
        )
      else
        # Simple fallback with basic personality
        npc = Npc.new(
          campaign: session.campaign,
          name: params[:name] || spawner.send(:generate_name),
          occupation: params[:occupation] || 'Commoner',
          age: rand(18..70)
        )
        personality = spawner.generate_personality(occupation: npc.occupation)
        npc.assign_attributes(personality)
        spawner.assign_stats(npc, type: 'guard', character_level: character&.level || 1, combat_ready: false)
        npc.save!
        npc
      end

      success_result(
        "**#{npc.name}** appears (#{npc.occupation}, Level #{npc.level})\n\n" \
        "*Personality:* #{npc.personality_traits}\n" \
        "*Motivation:* #{npc.motivations}",
        npc_id: npc.id,
        npc_name: npc.name,
        npc_occupation: npc.occupation,
        npc_level: npc.level,
        combat_ready: npc.max_hit_points.present?
      )
    end

    # Generate NPC dialogue based on personality
    def npc_speak(params)
      npc_id = params[:npc_id]
      return error_result('NPC ID required') unless npc_id

      npc = Npc.find_by(id: npc_id)
      return error_result("NPC not found: #{npc_id}") unless npc

      dialogue_service = SoloPlay::NpcDialogueService.new(npc)

      # Determine dialogue type
      result = if params[:player_input]
        # Direct response to player
        dialogue_service.generate_response(
          player_input: params[:player_input],
          context: build_dialogue_context(params)
        )
      elsif params[:greeting]
        # Greeting
        dialogue_service.generate_greeting(
          character_id: character&.id,
          location: params[:location],
          time_of_day: params[:time_of_day]
        )
      elsif params[:topic]
        # Information request
        dialogue_service.generate_information(
          topic: params[:topic],
          character_id: character&.id
        )
      elsif params[:quest_request]
        # Quest offer
        quest_data = dialogue_service.generate_quest_request(character_id: character&.id)
        return success_result(
          "**#{npc.name}:** \"#{quest_data[:quest_description]}\"",
          npc_name: npc.name,
          quest_type: quest_data[:quest_type],
          dialogue: quest_data[:quest_description]
        )
      else
        # Ambient small talk
        dialogue_service.generate_small_talk(context: build_dialogue_context(params))
      end

      # Format response based on dialogue type
      dialogue_text = result.is_a?(Hash) ? result[:dialogue] : result

      success_result(
        "**#{npc.name}:** \"#{dialogue_text}\"",
        npc_name: npc.name,
        npc_occupation: npc.occupation,
        dialogue: dialogue_text,
        relationship_change: result.is_a?(Hash) ? result[:relationship_change] : nil,
        mood: result.is_a?(Hash) ? result[:mood] : nil
      )
    end

    # Generate NPC reaction to player action
    def npc_react(params)
      npc_id = params[:npc_id]
      return error_result('NPC ID and action required') unless npc_id && params[:action]

      npc = Npc.find_by(id: npc_id)
      return error_result("NPC not found: #{npc_id}") unless npc

      dialogue_service = SoloPlay::NpcDialogueService.new(npc)

      reaction = dialogue_service.generate_reaction(
        action: params[:action],
        outcome: params[:outcome] || 'unknown result',
        context: build_dialogue_context(params)
      )

      success_result(
        "**#{npc.name}** #{reaction}",
        npc_name: npc.name,
        reaction: reaction
      )
    end

    # ========================================
    # FACTION TOOLS
    # ========================================

    def create_faction(params)
      return error_result('Campaign required for faction creation') unless session.campaign

      # Get world and alignment if specified
      world = session.campaign.world
      alignment = Alignment.find_by(name: params[:alignment]) if params[:alignment]

      faction = Faction.new(
        campaign: session.campaign,
        world: world,
        name: params[:name],
        faction_type: params[:faction_type] || 'guild',
        description: params[:description],
        power_level: params[:power_level] || 5,
        alignment: alignment
      )

      # Add goals and territory if provided
      faction.goals = params[:goals] if params[:goals]
      faction.territory = { description: params[:territory] } if params[:territory]

      if faction.save
        # Record world state event
        if session.campaign.world_state
          state_tracker = WorldServices::StateTracker.new(session.campaign)
          state_tracker.record_event(
            event_type: :world_changed,
            description: "New faction emerged: #{faction.name} (#{faction.faction_type})",
            severity: :moderate,
            metadata: {
              faction_id: faction.id,
              faction_name: faction.name,
              faction_type: faction.faction_type,
              power_level: faction.power_level
            }
          )
        end

        success_result(
          "**#{faction.name}** has been established as a #{faction.faction_type}!\n\n" \
          "*Power Level:* #{faction.power_level}/10\n" \
          "#{faction.description ? "*Description:* #{faction.description}\n" : ''}" \
          "#{params[:territory] ? "*Territory:* #{params[:territory]}" : ''}",
          faction_id: faction.id,
          faction_name: faction.name,
          faction_type: faction.faction_type,
          power_level: faction.power_level
        )
      else
        error_result("Failed to create faction: #{faction.errors.full_messages.join(', ')}")
      end
    end

    def adjust_faction_reputation(params)
      return error_result('Campaign required') unless session.campaign
      return error_result('Character required') unless character

      faction = Faction.find_by(id: params[:faction_id])
      return error_result("Faction not found: #{params[:faction_id]}") unless faction

      target_character = if params[:character_id]
        Character.find_by(id: params[:character_id])
      else
        character
      end

      return error_result("Character not found: #{params[:character_id]}") unless target_character

      # Use FactionReputationManager
      reputation_manager = WorldServices::FactionReputationManager.new(session.campaign)
      result = reputation_manager.adjust_reputation(
        faction_id: faction.id,
        character: target_character,
        amount: params[:amount],
        reason: params[:reason]
      )

      level_change_msg = if result[:level_changed]
        "\n\n**Reputation level changed!** #{result[:old_reputation]} → #{result[:new_reputation]}"
      else
        ''
      end

      success_result(
        "Reputation with **#{result[:faction_name]}** adjusted by #{params[:amount] > 0 ? '+' : ''}#{params[:amount]}.\n" \
        "*Current standing:* #{result[:level].to_s.humanize} (#{result[:new_reputation]})" \
        "#{level_change_msg}",
        faction_id: result[:faction_id],
        faction_name: result[:faction_name],
        old_reputation: result[:old_reputation],
        new_reputation: result[:new_reputation],
        level: result[:level],
        level_changed: result[:level_changed]
      )
    end

    # ========================================
    # GAME STATE TOOLS
    # ========================================

    def roll_dice(params)
      # Parse dice expression
      match = params[:dice_expression].match(/(\d+)d(\d+)([+-]\d+)?/)
      return error_result("Invalid dice expression: #{params[:dice_expression]}") unless match

      num_dice = match[1].to_i
      die_size = match[2].to_i
      modifier = match[3]&.to_i || 0

      # Handle advantage/disadvantage for d20 rolls
      rolls = if params[:advantage] && die_size == 20
        [rand(1..20), rand(1..20)].max(1).map { |_| rand(1..die_size) }
      elsif params[:disadvantage] && die_size == 20
        [rand(1..20), rand(1..20)].min(1).map { |_| rand(1..die_size) }
      else
        num_dice.times.map { rand(1..die_size) }
      end

      total = rolls.sum + modifier

      result_data = {
        rolls: rolls,
        modifier: modifier,
        total: total,
        purpose: params[:purpose]
      }

      if params[:dc]
        result_data[:dc] = params[:dc]
        result_data[:success] = total >= params[:dc]
      end

      success_result(
        "Rolled #{params[:dice_expression]}: #{rolls.join('+')}#{modifier >= 0 ? "+#{modifier}" : modifier} = #{total}",
        result_data
      )
    end

    def validate_action(params)
      # Delegate to ActionValidator
      if defined?(SoloPlay::ActionValidator) && session.respond_to?(:solo_sessions)
        solo_session = session.solo_sessions.last
        validator = SoloPlay::ActionValidator.new(solo_session)
        result = validator.validate_action(params[:action_params] || {})
        return success_result(
          result[:valid] ? 'Action is valid' : result[:errors].join(', '),
          valid: result[:valid],
          errors: result[:errors],
          warnings: result[:warnings]
        )
      end

      success_result('Action validation not available', valid: true)
    end

    def explain_rule(params)
      # Delegate to RulesExplainer
      if defined?(Multiplayer::RulesExplainer)
        explainer = Multiplayer::RulesExplainer.new(character)

        explanation = case params[:topic].downcase
        when 'condition'
          explainer.condition_explanation(params[:specific])
        when 'damage_type'
          explainer.damage_type_explanation(params[:specific])
        when 'weapon_property'
          explainer.weapon_property_explanation(params[:specific])
        else
          "Rule explanation for #{params[:topic]}: #{params[:specific]}"
        end

        return success_result(explanation)
      end

      success_result("Rules explanation not available for #{params[:topic]}")
    end

    def rewind_turn(params)
      turns = params[:turns_back] || 1

      target_log = DmActionAuditLog
        .where(terminal_session: session)
        .where(execution_status: 'executed')
        .order(created_at: :desc)
        .offset(turns)
        .first

      return error_result("Cannot rewind that far - only #{DmActionAuditLog.where(terminal_session: session).count} actions in history") unless target_log

      # Restore state
      restore_state(target_log.state_before)

      # Mark intervening logs as rolled back
      DmActionAuditLog
        .where(terminal_session: session)
        .where('created_at > ?', target_log.created_at)
        .update_all(execution_status: 'rolled_back')

      success_result("Rewound #{turns} turn(s): #{params[:reason]}")
    end

    def adjust_hp(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      old_hp = char.hit_points_current
      delta = params[:delta]

      new_hp = if delta.negative?
        [old_hp + delta, 0].max
      else
        [old_hp + delta, char.hit_points_max].min
      end

      char.update!(hit_points_current: new_hp)

      success_result(
        "#{params[:reason]}: #{delta >= 0 ? '+' : ''}#{delta} HP",
        old_hp: old_hp,
        new_hp: new_hp,
        delta: delta
      )
    end

    def short_rest(params)
      tracker = character_combat_tracker(params[:character_id])
      return error_result('No combat tracker') unless tracker

      tracker.short_rest
      success_result('Short rest completed - resources recovered')
    end

    def long_rest(params)
      tracker = character_combat_tracker(params[:character_id])
      return error_result('No combat tracker') unless tracker

      tracker.long_rest

      # Also restore HP
      char = find_character(params[:character_id])
      char&.update!(hit_points_current: char.hit_points_max)

      success_result('Long rest completed - full recovery')
    end

    # ========================================
    # HELPER METHODS
    # ========================================

    def find_character(id = nil)
      id ? Character.find_by(id: id) : character
    end

    def character_combat_tracker(char_id = nil)
      char = find_character(char_id)
      char&.character_combat_tracker || char&.create_character_combat_tracker
    end

    def find_active_combat
      return nil unless character

      Combat.where(status: 'active')
            .joins(:combat_participants)
            .where(combat_participants: { character_id: character.id })
            .first
    end

    def capture_state
      return {} unless character

      {
        hp: character.hit_points_current,
        max_hp: character.hit_points_max,
        gold: character.gold,
        experience: character.experience,
        level: character.level,
        conditions: character_combat_tracker&.conditions || [],
        ability_scores: {
          strength: character.strength,
          dexterity: character.dexterity,
          constitution: character.constitution,
          intelligence: character.intelligence,
          wisdom: character.wisdom,
          charisma: character.charisma
        }
      }
    end

    def restore_state(state)
      return unless character && state.present?

      character.update!(
        hit_points_current: state[:hp] || state['hp'],
        hit_points_max: state[:max_hp] || state['max_hp'],
        gold: state[:gold] || state['gold'],
        experience: state[:experience] || state['experience'],
        level: state[:level] || state['level'],
        strength: state.dig(:ability_scores, :strength) || state.dig('ability_scores', 'strength'),
        dexterity: state.dig(:ability_scores, :dexterity) || state.dig('ability_scores', 'dexterity'),
        constitution: state.dig(:ability_scores, :constitution) || state.dig('ability_scores', 'constitution'),
        intelligence: state.dig(:ability_scores, :intelligence) || state.dig('ability_scores', 'intelligence'),
        wisdom: state.dig(:ability_scores, :wisdom) || state.dig('ability_scores', 'wisdom'),
        charisma: state.dig(:ability_scores, :charisma) || state.dig('ability_scores', 'charisma')
      )

      # Restore conditions
      tracker = character_combat_tracker
      tracker&.update!(conditions: state[:conditions] || state['conditions'] || [])
    end

    def validate_parameters(tool_config, parameters)
      tool_config[:parameters].each do |param_name, config|
        value = parameters[param_name] || parameters[param_name.to_s]

        if config[:required] && value.nil?
          return { valid: false, error: "Missing required parameter: #{param_name}" }
        end

        if config[:enum] && value && !config[:enum].include?(value.to_s)
          return { valid: false, error: "Invalid value for #{param_name}: #{value}. Must be one of: #{config[:enum].join(', ')}" }
        end

        if config[:min] && value && value < config[:min]
          return { valid: false, error: "#{param_name} must be at least #{config[:min]}" }
        end

        if config[:max] && value && value > config[:max]
          return { valid: false, error: "#{param_name} must be at most #{config[:max]}" }
        end
      end

      { valid: true }
    end

    def character_summary
      return {} unless character

      {
        id: character.id,
        name: character.name,
        race: character.race&.name,
        class: character.character_class&.name,
        level: character.level,
        hp: "#{character.hit_points_current}/#{character.hit_points_max}"
      }
    end

    # ========================================
    # D&D 5E MECHANICS TOOLS - Generated from MDSL
    # ========================================

    def make_skill_check(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      skill_name = params[:skill]
      dc = params[:dc]

      # Determine ability and modifier
      ability_map = {
        'athletics' => :strength,
        'acrobatics' => :dexterity, 'sleight_of_hand' => :dexterity, 'stealth' => :dexterity,
        'arcana' => :intelligence, 'history' => :intelligence, 'investigation' => :intelligence,
        'nature' => :intelligence, 'religion' => :intelligence,
        'animal_handling' => :wisdom, 'insight' => :wisdom, 'medicine' => :wisdom,
        'perception' => :wisdom, 'survival' => :wisdom,
        'deception' => :charisma, 'intimidation' => :charisma,
        'performance' => :charisma, 'persuasion' => :charisma
      }

      ability = ability_map[skill_name]
      return error_result("Unknown skill: #{skill_name}") unless ability

      ability_modifier = char.send("#{ability}_modifier")
      proficiency_bonus = ((char.level - 1) / 4) + 2
      is_proficient = char.respond_to?(:proficiencies) && char.proficiencies&.include?(skill_name)

      total_modifier = params[:modifier_override] || (ability_modifier + (is_proficient ? proficiency_bonus : 0))

      # Roll d20 with advantage/disadvantage
      roll = if params[:advantage] && params[:disadvantage]
               DiceRoller.roll('1d20')
             elsif params[:advantage]
               [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].max
             elsif params[:disadvantage]
               [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].min
             else
               DiceRoller.roll('1d20')
             end

      total = roll + total_modifier
      success = total >= dc
      margin = total - dc

      # Determine degree of success
      degree = if roll == 1
                 'critical_failure'
               elsif roll == 20
                 'critical_success'
               elsif margin >= 10
                 'exceptional_success'
               elsif margin >= 5
                 'success_with_style'
               elsif success
                 'success'
               elsif margin >= -5
                 'near_miss'
               else
                 'failure'
               end

      success_result(
        "#{char.name} rolled #{total} (#{roll}+#{total_modifier}) for #{skill_name} vs DC #{dc}: #{degree.humanize}",
        {
          success: success,
          roll: roll,
          modifier: total_modifier,
          total: total,
          dc: dc,
          margin: margin,
          degree: degree,
          skill: skill_name,
          ability: ability,
          proficient: is_proficient
        }
      )
    end

    def make_ability_check(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      ability_name = params[:ability].downcase
      valid_abilities = %w[strength dexterity constitution intelligence wisdom charisma]
      return error_result("Invalid ability: #{params[:ability]}") unless valid_abilities.include?(ability_name)

      dc = params[:dc]
      modifier = char.send("#{ability_name}_modifier")

      # Roll d20 with advantage/disadvantage
      roll = if params[:advantage] && params[:disadvantage]
               DiceRoller.roll('1d20')
             elsif params[:advantage]
               [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].max
             elsif params[:disadvantage]
               [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].min
             else
               DiceRoller.roll('1d20')
             end

      total = roll + modifier
      success = total >= dc

      success_result(
        "#{char.name} rolled #{total} (#{roll}+#{modifier}) for #{ability_name.upcase} check vs DC #{dc}: #{success ? 'Success' : 'Failure'}",
        {
          success: success,
          roll: roll,
          modifier: modifier,
          total: total,
          dc: dc,
          ability: ability_name,
          natural_20: roll == 20,
          natural_1: roll == 1
        }
      )
    end

    def make_saving_throw(params)
      char = find_character(params[:character_id])
      return error_result('Character not found') unless char

      # Normalize save type
      save_map = {
        'STR' => 'strength', 'DEX' => 'dexterity', 'CON' => 'constitution',
        'INT' => 'intelligence', 'WIS' => 'wisdom', 'CHA' => 'charisma'
      }
      ability_name = save_map[params[:save_type]&.upcase] || params[:save_type]&.downcase

      valid_abilities = %w[strength dexterity constitution intelligence wisdom charisma]
      return error_result("Invalid save type: #{params[:save_type]}") unless valid_abilities.include?(ability_name)

      dc = params[:dc]
      ability_modifier = char.send("#{ability_name}_modifier")
      proficiency_bonus = ((char.level - 1) / 4) + 2

      # Check if proficient in this save (simplified - would check class proficiencies)
      proficient_saves = []
      is_proficient = proficient_saves.include?(ability_name)

      total_modifier = ability_modifier + (is_proficient ? proficiency_bonus : 0)

      # Roll d20 with advantage/disadvantage
      roll = if params[:advantage] && params[:disadvantage]
               DiceRoller.roll('1d20')
             elsif params[:advantage]
               [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].max
             elsif params[:disadvantage]
               [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].min
             else
               DiceRoller.roll('1d20')
             end

      total = roll + total_modifier
      success = total >= dc

      success_result(
        "#{char.name} rolled #{total} (#{roll}+#{total_modifier}) for #{ability_name.upcase} save vs DC #{dc}: #{success ? 'Success' : 'Failure'}#{params[:source] ? " (#{params[:source]})" : ''}",
        {
          success: success,
          roll: roll,
          modifier: total_modifier,
          total: total,
          dc: dc,
          save_type: ability_name,
          source: params[:source],
          proficient: is_proficient,
          natural_20: roll == 20,
          natural_1: roll == 1
        }
      )
    end

    def make_attack(params)
      attacker = find_character(params[:attacker_id])
      return error_result('Attacker not found') unless attacker

      target = find_character(params[:target_id])
      return error_result('Target not found') unless target

      valid_attack_types = %w[melee ranged spell]
      return error_result("Invalid attack type: #{params[:attack_type]}") unless valid_attack_types.include?(params[:attack_type])

      # Determine attack modifier
      attack_modifier = case params[:attack_type]
                        when 'melee' then attacker.strength_modifier
                        when 'ranged' then attacker.dexterity_modifier
                        when 'spell' then attacker.intelligence_modifier
                        end

      proficiency_bonus = ((attacker.level - 1) / 4) + 2
      attack_bonus = attack_modifier + proficiency_bonus

      # Roll attack (d20)
      attack_roll = if params[:advantage] && params[:disadvantage]
                      DiceRoller.roll('1d20')
                    elsif params[:advantage]
                      [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].max
                    elsif params[:disadvantage]
                      [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].min
                    else
                      DiceRoller.roll('1d20')
                    end

      attack_total = attack_roll + attack_bonus
      target_ac = target.calculated_armor_class

      hit = attack_total >= target_ac
      critical = attack_roll == 20
      critical_miss = attack_roll == 1

      damage = 0
      damage_rolls = []
      weapon_name = params[:weapon_name] || 'Unarmed Strike'
      damage_dice = params[:damage_dice] || '1d4'
      damage_type = params[:damage_type] || 'bludgeoning'

      if hit || critical
        # Roll damage
        if critical
          # Critical hit - double damage dice
          damage_rolls << DiceRoller.roll(damage_dice)
          damage_rolls << DiceRoller.roll(damage_dice)
          damage = damage_rolls.sum + attack_modifier
        else
          damage_roll = DiceRoller.roll(damage_dice)
          damage_rolls << damage_roll
          damage = damage_roll + attack_modifier
        end

        damage = [damage, 1].max # Minimum 1 damage on hit
      end

      result_message = if critical
                         "#{attacker.name} **CRITICAL HIT** with #{weapon_name}! Rolled #{attack_total} vs AC #{target_ac}. #{damage} #{damage_type} damage!"
                       elsif critical_miss
                         "#{attacker.name} **CRITICAL MISS** with #{weapon_name}! Rolled a natural 1."
                       elsif hit
                         "#{attacker.name} hits #{target.name} with #{weapon_name}! Rolled #{attack_total} vs AC #{target_ac}. #{damage} #{damage_type} damage."
                       else
                         "#{attacker.name} misses #{target.name} with #{weapon_name}. Rolled #{attack_total} vs AC #{target_ac}."
                       end

      success_result(
        result_message,
        {
          hit: hit,
          critical: critical,
          critical_miss: critical_miss,
          attack_roll: attack_roll,
          attack_bonus: attack_bonus,
          attack_total: attack_total,
          target_ac: target_ac,
          damage: damage,
          damage_rolls: damage_rolls,
          damage_type: damage_type,
          weapon: weapon_name
        }
      )
    end

    def cast_spell(params)
      caster = find_character(params[:caster_id])
      return error_result('Caster not found') unless caster

      target_ids = params[:target_ids].is_a?(Array) ? params[:target_ids] : [params[:target_ids]]
      targets = Character.where(id: target_ids)

      return error_result('No valid targets found') if targets.empty?

      spell_name = params[:spell_name]
      spell_level = params[:spell_level] || 1

      # Calculate spell save DC if not provided
      spell_save_dc = params[:spell_save_dc] || (8 + caster.intelligence_modifier + ((caster.level - 1) / 4 + 2))

      # Simplified spell system - would look up from Spell model in real system
      results = targets.map do |target|
        {
          target_id: target.id,
          target_name: target.name,
          spell_save_dc: spell_save_dc,
          effect: "#{spell_name} cast on #{target.name}"
        }
      end

      success_result(
        "#{caster.name} casts **#{spell_name}** (level #{spell_level}) targeting #{targets.map(&:name).join(', ')}",
        {
          caster_id: caster.id,
          caster_name: caster.name,
          spell_name: spell_name,
          spell_level: spell_level,
          spell_save_dc: spell_save_dc,
          targets_affected: results.size,
          results: results
        }
      )
    end

    def success_result(message, data = {})
      { success: true, message: message }.merge(data)
    end

    def error_result(message)
      @errors << message
      { success: false, error: message, errors: @errors }
    end

    def broadcast_state_change(tool_name, result)
      ActionCable.server.broadcast(
        "terminal_session_#{session.id}",
        {
          type: 'state_change',
          tool_name: tool_name,
          result: result,
          timestamp: Time.current.iso8601
        }
      )
    end

    def broadcast_pending_action(pending_action)
      ActionCable.server.broadcast(
        "terminal_session_#{session.id}",
        {
          type: 'pending_action',
          action: {
            id: pending_action.id,
            tool_name: pending_action.tool_name,
            description: pending_action.description,
            dm_reasoning: pending_action.dm_reasoning,
            expires_at: pending_action.expires_at&.iso8601,
            requires_approval: true
          }
        }
      )
    end

    def build_dialogue_context(params)
      {
        character_id: character&.id,
        game_session_id: session.id,
        location: params[:location],
        recent_events: session.recent_events || [],
        interaction_type: params[:interaction_type] || 'conversation'
      }
    end

    # ========================================
    # HOMEBREW & TREASURE TOOL IMPLEMENTATIONS
    # ========================================

    def create_homebrew_item(params)
      # Validate item data
      validator = Homebrew::Validator.new
      item_data = {
        name: params[:name],
        description: params[:description],
        rarity: params[:rarity],
        item_type: params[:item_type],
        requires_attunement: params[:requires_attunement] || false,
        attunement_requirements: params[:attunement_requirements],
        properties: params[:properties],
        cursed: params[:cursed] || false
      }

      unless validator.validate_item(item_data)
        validation_result = validator.validation_result
        return error_result("Item validation failed: #{validation_result[:errors].join(', ')}")
      end

      # Create homebrew item
      homebrew_item = HomebrewItem.create!(
        campaign: session.campaign,
        creator: character,
        name: params[:name],
        description: params[:description],
        rarity: params[:rarity],
        item_type: params[:item_type],
        requires_attunement: params[:requires_attunement] || false,
        attunement_requirements: params[:attunement_requirements] || {},
        properties: params[:properties] || {},
        cursed: params[:cursed] || false,
        approved: false
      )

      # Grant to character if approved and requested
      if params[:grant_to_character]
        # This will happen in the approval callback
        homebrew_item.update(pending_grant_character_id: character&.id)
      end

      success_result(
        "Created homebrew item: #{params[:name]} (#{params[:rarity]}). #{validator.warnings.any? ? "Warnings: #{validator.warnings.join(', ')}" : 'No balance concerns detected.'}",
        homebrew_item_id: homebrew_item.id,
        validation_warnings: validator.warnings
      )
    end

    def generate_treasure(params)
      method = params[:method]

      treasure = case method
                 when 'loot_table'
                   return error_result('loot_table_id required for loot_table method') unless params[:loot_table_id]

                   loot_table = LootTable.find_by(id: params[:loot_table_id], campaign: session.campaign)
                   return error_result("Loot table not found: #{params[:loot_table_id]}") unless loot_table

                   generator = Treasure::Generator.new(
                     loot_table: loot_table,
                     campaign: session.campaign,
                     character: character
                   )
                   result = generator.generate
                   return error_result(result[:error]) unless result[:success]

                   result[:treasure]
                 when 'challenge_rating'
                   return error_result('challenge_rating required for challenge_rating method') unless params[:challenge_rating]

                   Treasure::Generator.generate_by_challenge_rating(
                     challenge_rating: params[:challenge_rating].to_f,
                     campaign: session.campaign,
                     character: character
                   )
                 else
                   return error_result("Invalid generation method: #{method}")
                 end

      # Grant treasure to character if requested
      if params[:grant_to_character] && character
        # Grant gold
        if treasure[:gold_pieces] && treasure[:gold_pieces] > 0
          character.update!(gold: (character.gold || 0) + treasure[:gold_pieces])
        elsif treasure[:total_gold_value] && treasure[:total_gold_value] > 0
          character.update!(gold: (character.gold || 0) + treasure[:total_gold_value].to_i)
        end

        # Grant items
        treasure[:items]&.each do |item_data|
          InventoryItem.create!(
            character: character,
            item_id: item_data[:item_id],
            name: item_data[:item_name] || 'Unknown Item',
            quantity: item_data[:quantity] || 1,
            equipped: false,
            properties: item_data[:treasure_data] || {}
          )
        end
      end

      formatted_treasure = format_treasure_summary(treasure)
      success_result("Generated treasure: #{formatted_treasure}", treasure: treasure)
    end

    def create_loot_table(params)
      loot_table = LootTable.create!(
        campaign: session.campaign,
        name: params[:name],
        description: params[:description]
      )

      # Create entries
      params[:entries].each do |entry_data|
        LootTableEntry.create!(
          loot_table: loot_table,
          treasure_type: entry_data[:treasure_type] || 'gold',
          weight: entry_data[:weight] || 1,
          quantity_dice: entry_data[:quantity_dice],
          item_id: entry_data[:item_id],
          treasure_data: entry_data[:treasure_data] || {}
        )
      end

      success_result(
        "Created loot table: #{params[:name]} with #{params[:entries].length} entries",
        loot_table_id: loot_table.id
      )
    end

    def grant_homebrew_item(params)
      homebrew_item = HomebrewItem.find_by(id: params[:homebrew_item_id], campaign: session.campaign)
      return error_result("Homebrew item not found: #{params[:homebrew_item_id]}") unless homebrew_item

      target_character = params[:character_id] ? Character.find(params[:character_id]) : character
      return error_result('No character specified') unless target_character

      quantity = params[:quantity] || 1

      inventory_item = InventoryItem.create!(
        character: target_character,
        homebrew_item: homebrew_item,
        name: homebrew_item.name,
        quantity: quantity,
        equipped: false,
        identified: params[:identified] || false,
        attuned: params[:attuned] || false,
        properties: homebrew_item.properties
      )

      success_result(
        "Granted #{quantity}x #{homebrew_item.name} to #{target_character.name}",
        inventory_item_id: inventory_item.id
      )
    end

    def attune_item(params)
      target_character = params[:character_id] ? Character.find(params[:character_id]) : character
      return error_result('No character specified') unless target_character

      inventory_item = InventoryItem.find_by(id: params[:inventory_item_id], character: target_character)
      return error_result("Item not found in character inventory") unless inventory_item

      # Check attunement slots (max 3 in D&D 5e)
      attuned_count = target_character.inventory_items.where(attuned: true).count
      if attuned_count >= 3 && !inventory_item.attuned
        return error_result("#{target_character.name} already has 3 attuned items (maximum)")
      end

      # Check if item requires attunement
      requires_attunement = inventory_item.properties['requires_attunement'] ||
                            inventory_item.homebrew_item&.requires_attunement ||
                            false

      unless requires_attunement
        return error_result("#{inventory_item.name} does not require attunement")
      end

      inventory_item.update!(attuned: true)

      success_result(
        "#{target_character.name} is now attuned to #{inventory_item.name}",
        inventory_item_id: inventory_item.id
      )
    end

    def identify_item(params)
      inventory_item = InventoryItem.find_by(id: params[:inventory_item_id])
      return error_result("Item not found") unless inventory_item

      inventory_item.update!(identified: true)

      properties_summary = format_item_properties(inventory_item)

      success_result(
        "Identified #{inventory_item.name}: #{properties_summary}",
        inventory_item_id: inventory_item.id,
        properties: inventory_item.properties
      )
    end

    def remove_item(params)
      target_character = params[:character_id] ? Character.find(params[:character_id]) : character
      return error_result('No character specified') unless target_character

      inventory_item = InventoryItem.find_by(id: params[:inventory_item_id], character: target_character)
      return error_result("Item not found in character inventory") unless inventory_item

      quantity_to_remove = params[:quantity] || 1
      current_quantity = inventory_item.quantity || 1

      if quantity_to_remove >= current_quantity
        # Remove entire stack
        item_name = inventory_item.name
        inventory_item.destroy!
        message = "Removed #{current_quantity}x #{item_name} from #{target_character.name}'s inventory (#{params[:reason]})"
      else
        # Reduce quantity
        inventory_item.update!(quantity: current_quantity - quantity_to_remove)
        message = "Removed #{quantity_to_remove}x #{inventory_item.name} from #{target_character.name}'s inventory (#{params[:reason]})"
      end

      success_result(message)
    end

    def create_homebrew_spell(params)
      # Validate spell data
      validator = Homebrew::Validator.new
      spell_data = {
        name: params[:name],
        description: params[:description],
        level: params[:level],
        school: params[:school],
        casting_time: params[:casting_time],
        range: params[:range],
        components: params[:components],
        duration: params[:duration]
      }

      unless validator.validate_spell(spell_data)
        validation_result = validator.validation_result
        return error_result("Spell validation failed: #{validation_result[:errors].join(', ')}")
      end

      # Create homebrew spell
      homebrew_spell = HomebrewSpell.create!(
        campaign: session.campaign,
        creator: character,
        name: params[:name],
        description: params[:description],
        level: params[:level],
        school: params[:school],
        casting_time: params[:casting_time],
        range: params[:range],
        components: params[:components],
        duration: params[:duration],
        damage_dice: params[:damage_dice],
        damage_type: params[:damage_type],
        save_type: params[:save_type],
        available_to_classes: params[:available_to_classes] || [],
        approved: false
      )

      success_result(
        "Created homebrew spell: #{params[:name]} (Level #{params[:level]} #{params[:school]}). #{validator.warnings.any? ? "Warnings: #{validator.warnings.join(', ')}" : 'No balance concerns detected.'}",
        homebrew_spell_id: homebrew_spell.id,
        validation_warnings: validator.warnings
      )
    end

    def list_homebrew(params)
      content_type = params[:content_type] || 'all'

      result = {
        items: [],
        spells: [],
        feats: [],
        features: []
      }

      if ['items', 'all'].include?(content_type)
        result[:items] = HomebrewItem.where(campaign: session.campaign)
                                      .order(created_at: :desc)
                                      .limit(20)
                                      .map { |item| format_homebrew_item_summary(item) }
      end

      if ['spells', 'all'].include?(content_type)
        result[:spells] = HomebrewSpell.where(campaign: session.campaign)
                                        .order(created_at: :desc)
                                        .limit(20)
                                        .map { |spell| format_homebrew_spell_summary(spell) }
      end

      total_count = result.values.flatten.count

      success_result(
        "Found #{total_count} homebrew #{content_type} for this campaign",
        homebrew: result
      )
    end

    # Helper methods for homebrew/treasure

    def format_treasure_summary(treasure)
      parts = []

      if treasure[:gold_pieces]
        parts << "#{treasure[:gold_pieces]} gold"
      elsif treasure[:total_gold_value]
        gold_value = treasure[:total_gold_value].to_i
        parts << "#{gold_value} gold value"
        parts << "(#{treasure[:copper_pieces]}cp, #{treasure[:silver_pieces]}sp, #{treasure[:electrum_pieces]}ep, #{treasure[:gold_pieces]}gp, #{treasure[:platinum_pieces]}pp)" if treasure[:copper_pieces]
      end

      if treasure[:items] && treasure[:items].any?
        parts << "#{treasure[:items].length} items"
      end

      parts.join(', ')
    end

    def format_item_properties(inventory_item)
      props = inventory_item.properties || {}
      parts = []

      parts << "#{props['rarity']&.titleize}" if props['rarity']
      parts << "#{props['item_type']&.titleize}" if props['item_type']
      parts << "+#{props['attack_bonus']} to attack" if props['attack_bonus']
      parts << "+#{props['damage_bonus']} to damage" if props['damage_bonus']
      parts << "#{props['damage_dice']} #{props['damage_type']} damage" if props['damage_dice']
      parts << "+#{props['ac_bonus']} AC" if props['ac_bonus']
      parts << "Requires attunement" if props['requires_attunement']
      parts << "Cursed" if props['cursed']

      parts.any? ? parts.join(', ') : 'No special properties'
    end

    def format_homebrew_item_summary(item)
      {
        id: item.id,
        name: item.name,
        rarity: item.rarity,
        item_type: item.item_type,
        requires_attunement: item.requires_attunement,
        approved: item.approved,
        created_at: item.created_at.iso8601
      }
    end

    def format_homebrew_spell_summary(spell)
      {
        id: spell.id,
        name: spell.name,
        level: spell.level,
        school: spell.school,
        approved: spell.approved,
        created_at: spell.created_at.iso8601
      }
    end

    # Automatic treasure generation after combat victory
    def generate_combat_treasure(combat)
      # Calculate total CR from defeated enemies
      total_cr = combat.combat_participants
                      .joins(:encounter_monster)
                      .includes(encounter_monster: :monster)
                      .sum { |participant| participant.encounter_monster&.challenge_rating || 0 }

      # No treasure if no monsters were defeated
      return nil if total_cr.zero?

      # Adjust CR for balance (use average CR if multiple monsters)
      monster_count = combat.combat_participants.joins(:encounter_monster).count
      average_cr = monster_count > 0 ? (total_cr / monster_count.to_f).round : total_cr

      # Generate treasure by CR using Treasure::Generator
      begin
        treasure_data = Treasure::Generator.generate_by_challenge_rating(
          challenge_rating: average_cr,
          campaign: session.campaign,
          character: character
        )

        # Add gold to character
        if treasure_data[:total_gold_value] && character
          character.update!(gold: character.gold + treasure_data[:total_gold_value])
        end

        {
          generated: true,
          total_cr: total_cr,
          average_cr: average_cr,
          treasure: treasure_data,
          summary: format_treasure_summary(treasure_data)
        }
      rescue StandardError => e
        Rails.logger.error("Failed to generate combat treasure: #{e.message}")
        nil
      end
    end

    # Enrich result with contextual suggestions
    def enrich_with_suggestions(tool_name, result)
      return unless character

      suggestion_engine = AiDm::SuggestionEngine.new(character, session)
      suggestions = suggestion_engine.suggestions_after_tool(tool_name, result)

      result[:suggestions] = suggestions if suggestions.any?
    rescue StandardError => e
      Rails.logger.error("Failed to generate suggestions: #{e.message}")
      # Don't fail the tool execution if suggestions fail
    end

    # Check if character is locked for this specific tool
    def character_locked_for_tool?(tool_name)
      return false unless session.character_locked

      # Tools that modify core character attributes
      locked_tools = %i[
        set_ability_score
        modify_backstory
        grant_skill_proficiency
        change_race
        change_class
      ]

      # Always allow gameplay mechanics even when locked
      allowed_tools = %i[
        add_item_to_inventory
        remove_item_from_inventory
        adjust_hit_points
        add_condition
        remove_condition
        roll_dice
        cast_spell
        attack
        rest
      ]

      return false if allowed_tools.include?(tool_name.to_sym)
      locked_tools.include?(tool_name.to_sym)
    end
  end
end
