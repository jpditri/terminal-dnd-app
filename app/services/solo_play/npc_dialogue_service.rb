# frozen_string_literal: true

module SoloPlay
  # NpcDialogueService generates contextual NPC conversations
  # Uses AI to create personality-driven dialogue based on NPC traits
  class NpcDialogueService
    attr_reader :npc, :ai_client, :conversation_memory

    def initialize(npc)
      @npc = npc
      @ai_client = initialize_ai_client
      @conversation_memory = load_conversation_memory
    end

    # Generate NPC response to player action/dialogue
    def generate_response(player_input:, context: {})
      # Build personality-driven prompt
      prompt = build_dialogue_prompt(player_input, context)
      system_context = build_npc_persona

      # Generate AI response
      response = ai_client.generate(
        prompt: prompt,
        system: system_context,
        temperature: 0.8, # Higher temperature for more varied personality
        max_tokens: 300
      )

      dialogue = response[:content]

      # Record interaction and update memory
      interaction = record_interaction(
        player_action: player_input,
        npc_response: dialogue,
        context: context
      )

      # Analyze relationship change
      relationship_delta = analyze_relationship_change(player_input, dialogue)
      update_relationship(relationship_delta, context[:character_id]) if relationship_delta.nonzero?

      {
        dialogue: dialogue,
        interaction_id: interaction.id,
        relationship_change: relationship_delta,
        mood: infer_mood(dialogue)
      }
    end

    # Generate NPC greeting based on relationship and context
    def generate_greeting(character_id:, location: nil, time_of_day: nil)
      relationship_level = get_relationship_level(character_id)
      context_info = build_context_string(location, time_of_day)

      prompt = "The character approaches #{npc.name}. #{context_info}. " \
               "Based on your relationship (#{relationship_level}), how do you greet them? " \
               "Respond in character, showing your personality."

      response = ai_client.generate(
        prompt: prompt,
        system: build_npc_persona,
        temperature: 0.9,
        max_tokens: 150
      )

      record_interaction(
        player_action: 'Approached NPC',
        npc_response: response[:content],
        context: { character_id: character_id, location: location, interaction_type: 'greeting' }
      )

      response[:content]
    end

    # Generate NPC reaction to player action (combat, skill check, etc.)
    def generate_reaction(action:, outcome:, context: {})
      prompt = "The character #{action} with outcome: #{outcome}. " \
               "How do you react based on your personality and motivations? " \
               "Keep it brief (1-2 sentences)."

      response = ai_client.generate(
        prompt: prompt,
        system: build_npc_persona,
        temperature: 0.8,
        max_tokens: 100
      )

      record_interaction(
        player_action: "#{action} (#{outcome})",
        npc_response: response[:content],
        context: context.merge(interaction_type: 'reaction')
      )

      response[:content]
    end

    # Generate NPC quest/request based on personality and motivations
    def generate_quest_request(character_id:)
      relationship_level = get_relationship_level(character_id)

      prompt = "Based on your motivations (#{npc.motivations}) and current relationship " \
               "(#{relationship_level}), what favor or quest would you ask of this character? " \
               "Be specific and in-character. Include what you're willing to offer in return."

      response = ai_client.generate(
        prompt: prompt,
        system: build_npc_persona,
        temperature: 0.7,
        max_tokens: 400
      )

      record_interaction(
        player_action: 'Asked if NPC needs help',
        npc_response: response[:content],
        context: { character_id: character_id, interaction_type: 'quest_offer' }
      )

      {
        quest_description: response[:content],
        quest_type: infer_quest_type(response[:content])
      }
    end

    # Generate NPC information/rumor based on knowledge and personality
    def generate_information(topic:, character_id:)
      relationship_level = get_relationship_level(character_id)

      # NPCs share more with higher relationship
      willingness = case relationship_level
                    when 'hostile' then 'very reluctant'
                    when 'unfriendly' then 'hesitant'
                    when 'neutral' then 'willing if it benefits you'
                    when 'friendly' then 'eager'
                    when 'allied' then 'completely open'
                    else 'neutral'
                    end

      prompt = "The character asks you about: #{topic}. " \
               "You are #{willingness} to share information. " \
               "Based on your occupation (#{npc.occupation}) and secrets (#{npc.secrets}), " \
               "what do you tell them? Stay in character."

      response = ai_client.generate(
        prompt: prompt,
        system: build_npc_persona,
        temperature: 0.75,
        max_tokens: 250
      )

      record_interaction(
        player_action: "Asked about: #{topic}",
        npc_response: response[:content],
        context: { character_id: character_id, interaction_type: 'information' }
      )

      response[:content]
    end

    # Generate NPC small talk/ambient dialogue
    def generate_small_talk(context: {})
      prompt = "Generate a brief piece of small talk or an offhand comment your character " \
               "might make in this moment. Stay true to your personality and current context. " \
               "1 sentence maximum."

      response = ai_client.generate(
        prompt: prompt,
        system: build_npc_persona,
        temperature: 0.9,
        max_tokens: 80
      )

      response[:content]
    end

    # Update NPC's conversation memory (stores recent interactions)
    def update_memory(key, value)
      memory = npc.conversation_memory || {}
      memory[key.to_s] = value
      npc.update!(conversation_memory: memory)
    end

    # Retrieve from NPC's conversation memory
    def recall_memory(key)
      return nil unless npc.conversation_memory.present?
      npc.conversation_memory[key.to_s]
    end

    private

    def initialize_ai_client
      # Use same AI client as DM (Anthropic or Ollama)
      if ENV['ANTHROPIC_API_KEY'].present?
        AnthropicClient.new
      else
        OllamaClient.new
      end
    end

    def load_conversation_memory
      npc.conversation_memory || {}
    end

    def build_npc_persona
      <<~PERSONA
        You are roleplaying as #{npc.name}, a #{npc.age}-year-old #{npc.occupation}.

        PERSONALITY:
        - Traits: #{npc.personality_traits}
        - Ideals: #{npc.ideals}
        - Bonds: #{npc.bonds}
        - Flaws: #{npc.flaws}
        - Voice Style: #{npc.voice_style}
        - Speech Patterns: #{npc.speech_patterns}

        MOTIVATIONS: #{npc.motivations}
        SECRET: #{npc.secrets}

        BACKSTORY: #{npc.backstory}

        INSTRUCTIONS:
        - Stay completely in character at all times
        - Use your voice style and speech patterns
        - Let your personality traits guide your reactions
        - Your motivations drive your goals in conversations
        - Keep your secret hidden unless trust is very high
        - Respond naturally as this character would
        - Keep responses concise and focused
      PERSONA
    end

    def build_dialogue_prompt(player_input, context)
      location_context = context[:location] ? " at #{context[:location]}" : ""
      recent_events = context[:recent_events] || "nothing unusual recently"

      <<~PROMPT
        The character says to you#{location_context}: "#{player_input}"

        Recent context: #{recent_events}

        How do you respond? Stay in character and be natural.
      PROMPT
    end

    def build_context_string(location, time_of_day)
      parts = []
      parts << "You are at #{location}" if location
      parts << "it is #{time_of_day}" if time_of_day
      parts.any? ? parts.join(' and ') : 'The character approaches you'
    end

    def record_interaction(player_action:, npc_response:, context: {})
      interaction = npc.npc_interactions.create!(
        character_id: context[:character_id],
        game_session_id: context[:game_session_id],
        interaction_type: context[:interaction_type] || 'conversation',
        player_action: player_action,
        npc_response: npc_response,
        occurred_at: Time.current,
        metadata: context.except(:character_id, :game_session_id, :interaction_type)
      )

      # Update conversation memory
      update_memory('last_interaction', {
        player_said: player_action,
        npc_said: npc_response,
        timestamp: Time.current.to_i
      })

      interaction
    end

    def analyze_relationship_change(player_input, npc_response)
      # Simple sentiment analysis based on NPC response
      # Positive words increase relationship, negative decrease it
      positive_words = %w[thank pleased glad happy appreciate wonderful excellent friend ally help]
      negative_words = %w[angry upset disappointed displeased hate annoyed frustrated worried concern]

      response_lower = npc_response.downcase
      positive_count = positive_words.count { |word| response_lower.include?(word) }
      negative_count = negative_words.count { |word| response_lower.include?(word) }

      # Net change (positive increases relationship by +1 to +5, negative decreases)
      net_change = (positive_count - negative_count).clamp(-5, 5)

      # Personality modifiers
      net_change += 1 if npc.personality_traits&.downcase&.include?('friendly')
      net_change -= 1 if npc.personality_traits&.downcase&.include?('suspicious')

      net_change
    end

    def update_relationship(delta, character_id)
      return unless character_id

      relationships = npc.relationships || {}
      current_value = relationships[character_id.to_s]&.to_i || 0
      new_value = (current_value + delta).clamp(-100, 100)

      relationships[character_id.to_s] = new_value
      npc.update!(relationships: relationships)

      # Record the change
      last_interaction = npc.npc_interactions.order(created_at: :desc).first
      last_interaction&.update!(relationship_change: delta)
    end

    def get_relationship_level(character_id)
      return 'neutral' unless character_id

      value = npc.relationships&.dig(character_id.to_s)&.to_i || 0

      case value
      when -100..-50 then 'hostile'
      when -49..-10 then 'unfriendly'
      when -9..9 then 'neutral'
      when 10..49 then 'friendly'
      when 50..100 then 'allied'
      else 'neutral'
      end
    end

    def infer_mood(dialogue)
      # Simple mood inference from dialogue
      dialogue_lower = dialogue.downcase

      return 'angry' if dialogue_lower.match?(/angry|furious|rage|damn/)
      return 'happy' if dialogue_lower.match?(/happy|glad|wonderful|excellent/)
      return 'worried' if dialogue_lower.match?(/worried|concerned|afraid|scared/)
      return 'suspicious' if dialogue_lower.match?(/suspicious|doubt|trust/)
      return 'friendly' if dialogue_lower.match?(/friend|welcome|pleased/)

      'neutral'
    end

    def infer_quest_type(quest_description)
      desc_lower = quest_description.downcase

      return 'combat' if desc_lower.match?(/kill|defeat|fight|attack|bandit|monster/)
      return 'retrieval' if desc_lower.match?(/find|retrieve|bring|fetch|get/)
      return 'delivery' if desc_lower.match?(/deliver|take|bring|send/)
      return 'escort' if desc_lower.match?(/escort|protect|guard|accompany/)
      return 'investigation' if desc_lower.match?(/investigate|discover|learn|find out/)
      return 'social' if desc_lower.match?(/convince|persuade|negotiate|talk/)

      'misc'
    end
  end
end
