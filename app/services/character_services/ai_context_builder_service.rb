# frozen_string_literal: true

module CharacterServices
  class AiContextBuilderService
    attr_reader :solo_session

    def initialize(solo_session: SoloSession.new)
      @solo_session = solo_session
    end


    def build_context_payload(ai_model: 'claude-3')
      # TODO: Implement
    end

    def extract_from_session_recap(recap_text, session_number: nil)
      # TODO: Implement
    end

    def analyze_character_personality
      # TODO: Implement
    end

    def update_from_conversation(messages)
      # TODO: Implement
    end

    def check_consistency(proposed_content)
      # TODO: Implement
    end

    def generate_context_summary
      # TODO: Implement
    end

    def seed_context(seed_text, preferences = {})
      # TODO: Implement
    end

    def compress_old_sessions
      # TODO: Implement
    end
  end
end