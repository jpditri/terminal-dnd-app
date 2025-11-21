# frozen_string_literal: true

module CharacterServices
  class AiAssistantService
    attr_reader :use_ai, :ai_client

    def initialize(use_ai: UseAi.new, ai_client: AiClient.new)
      @use_ai = use_ai
      @ai_client = ai_client
    end


    def initialize_assistant(tone: 'Helpful', knowledge_focus: 'Both', proactivity_level: 'Suggestive')
      # TODO: Implement
    end

    def chat(message)
      # TODO: Implement
    end

    def generate_roleplay_suggestion(situation)
      # TODO: Implement
    end

    def generate_dialogue(context, action_type = 'general')
      # TODO: Implement
    end

    def provide_tactical_advice(combat_situation)
      # TODO: Implement
    end

    def suggest_spell_preparation(adventure_context)
      # TODO: Implement
    end

    def generate_backstory(keywords = [])
      # TODO: Implement
    end

    def fill_backstory_gap(gap_description)
      # TODO: Implement
    end

    def create_session_summary(session_events)
      # TODO: Implement
    end

    def write_journal_entry(session_events)
      # TODO: Implement
    end

    def answer_rules_question(question, house_rules = {})
      # TODO: Implement
    end

    def optimize_character_build
      # TODO: Implement
    end

    def generate_catchphrases
      # TODO: Implement
    end

    def usage_stats
      # TODO: Implement
    end
  end
end