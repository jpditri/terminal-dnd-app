# frozen_string_literal: true

module Player
  # Analyzes player intent and preferences to adapt DM style
  # Tracks action patterns, message themes, and engagement signals
  # Provides recommendations for AI DM to match player playstyle
  class IntentAnalyzer
    LOOKBACK_HOURS = 4 # Analyze last 4 hours of gameplay
    LOOKBACK_MESSAGES = 30 # Or last 30 player messages
    LOOKBACK_ACTIONS = 30 # Last 30 DM actions

    # Intent categories based on player behavior
    INTENT_PATTERNS = {
      combat_focused: {
        keywords: %w[attack fight combat kill damage weapon spell cast hit strike],
        tools: %w[start_combat apply_damage use_action attack_with_weapon cast_spell],
        weight: 1.0
      },
      exploration_focused: {
        keywords: %w[search look investigate examine explore discover find check room area],
        tools: %w[create_quest discover_location search_area],
        weight: 1.0
      },
      roleplay_focused: {
        keywords: %w[talk speak say ask tell persuade charm intimidate performance],
        tools: %w[spawn_npc create_dialogue persuade_npc],
        weight: 1.0
      },
      tactical: {
        keywords: %w[plan strategy position advantage flanking cover distance range],
        tools: %w[use_action next_turn rewind_turn],
        weight: 0.8
      },
      loot_focused: {
        keywords: %w[loot gold treasure chest reward item equipment magic],
        tools: %w[grant_item grant_gold discover_treasure],
        weight: 0.7
      },
      story_focused: {
        keywords: %w[why who what backstory history lore learn knowledge quest],
        tools: %w[create_quest modify_backstory],
        weight: 0.8
      },
      mechanical: {
        keywords: %w[stats ability score modifier level up class feature],
        tools: %w[set_ability_score level_up],
        weight: 0.6
      }
    }.freeze

    # Engagement signals
    ENGAGEMENT_INDICATORS = {
      high_engagement: {
        message_frequency: 5,  # 5+ messages per hour
        avg_message_length: 50, # 50+ characters average
        question_rate: 0.3     # 30% messages contain questions
      },
      exploration_depth: {
        follow_up_rate: 0.4,   # 40% messages reference previous context
        detail_keywords: %w[carefully thoroughly closely examine detail]
      },
      creative_expression: {
        first_person_rate: 0.5, # 50% messages use "I" or "my"
        emotive_keywords: %w[feel think wonder hope worry fear excited curious]
      }
    }.freeze

    attr_reader :session, :character

    def initialize(terminal_session)
      @session = terminal_session
      @character = session.character
    end

    # Get comprehensive intent analysis
    def analyze
      player_messages = fetch_player_messages
      dm_actions = fetch_dm_actions

      return minimal_analysis if player_messages.count < 5

      intent_scores = calculate_intent_scores(player_messages, dm_actions)
      engagement_metrics = calculate_engagement(player_messages)
      preferences = detect_preferences(player_messages, dm_actions)

      {
        primary_intent: determine_primary_intent(intent_scores),
        secondary_intent: determine_secondary_intent(intent_scores),
        intent_scores: intent_scores,
        engagement: engagement_metrics,
        preferences: preferences,
        recommendations: generate_recommendations(intent_scores, engagement_metrics, preferences),
        confidence: calculate_confidence(player_messages.count),
        message_count: player_messages.count,
        action_count: dm_actions.count
      }
    end

    # Get quick context message for AI DM
    def dm_context_message
      analysis = analyze
      return nil if analysis[:confidence] < 30 # Not enough data

      messages = []

      # Primary intent
      if analysis[:primary_intent]
        messages << "Player shows #{analysis[:primary_intent].to_s.humanize.downcase} playstyle"
      end

      # Engagement level
      if analysis[:engagement][:level] == :high
        messages << "highly engaged (asking questions, providing detail)"
      elsif analysis[:engagement][:level] == :low
        messages << "less engaged (shorter responses)"
      end

      # Top recommendation
      if analysis[:recommendations].any?
        messages << analysis[:recommendations].first
      end

      return nil if messages.empty?
      messages.join('; ')
    end

    # Check if player prefers specific content type
    def prefers?(content_type)
      analysis = analyze
      return false unless analysis[:intent_scores][content_type]

      score = analysis[:intent_scores][content_type]
      avg_score = analysis[:intent_scores].values.sum / analysis[:intent_scores].count.to_f

      score > avg_score * 1.3 # 30% above average
    end

    # Get recommended DM style adjustments
    def style_recommendations
      analysis = analyze
      recommendations = []

      case analysis[:primary_intent]
      when :combat_focused
        recommendations << "Provide tactical combat descriptions with positioning details"
        recommendations << "Offer combat challenges and enemy variety"
      when :roleplay_focused
        recommendations << "Emphasize NPC personalities and dialogue opportunities"
        recommendations << "Create morally complex social situations"
      when :exploration_focused
        recommendations << "Describe environments richly with hidden details"
        recommendations << "Reward thorough investigation with discoveries"
      when :story_focused
        recommendations << "Weave plot threads and foreshadowing"
        recommendations << "Connect events to character backstory"
      end

      # Engagement-based adjustments
      if analysis[:engagement][:level] == :high
        recommendations << "Player is highly engaged - maintain current pacing"
      elsif analysis[:engagement][:level] == :low
        recommendations << "Try hooks to re-engage: mysteries, conflicts, or personal stakes"
      end

      recommendations
    end

    private

    def fetch_player_messages
      cutoff_time = LOOKBACK_HOURS.hours.ago

      NarrativeOutput
        .where(terminal_session: session)
        .where(content_type: 'player')
        .where('created_at >= ?', cutoff_time)
        .order(created_at: :desc)
        .limit(LOOKBACK_MESSAGES)
        .to_a
        .reverse
    end

    def fetch_dm_actions
      cutoff_time = LOOKBACK_HOURS.hours.ago

      DmActionAuditLog
        .where(terminal_session: session)
        .where(execution_status: 'executed')
        .where('created_at >= ?', cutoff_time)
        .order(created_at: :desc)
        .limit(LOOKBACK_ACTIONS)
        .to_a
        .reverse
    end

    def calculate_intent_scores(messages, actions)
      scores = {}

      INTENT_PATTERNS.each do |intent, pattern|
        message_score = score_messages_for_intent(messages, pattern[:keywords])
        action_score = score_actions_for_intent(actions, pattern[:tools])

        # Weighted combination
        total_score = (message_score * 0.6 + action_score * 0.4) * pattern[:weight]
        scores[intent] = total_score.round(2)
      end

      scores
    end

    def score_messages_for_intent(messages, keywords)
      return 0.0 if messages.empty?

      total_matches = messages.sum do |message|
        content = message.content.downcase
        keywords.count { |keyword| content.include?(keyword) }
      end

      # Normalize by message count
      (total_matches.to_f / messages.count).round(2)
    end

    def score_actions_for_intent(actions, tool_names)
      return 0.0 if actions.empty?

      matching_actions = actions.count do |action|
        tool_names.include?(action.tool_name)
      end

      # Percentage of actions matching this intent
      (matching_actions.to_f / actions.count).round(2)
    end

    def calculate_engagement(messages)
      return { level: :unknown, metrics: {} } if messages.empty?

      # Time span
      time_span = (messages.last.created_at - messages.first.created_at) / 1.hour
      time_span = [time_span, 1.0].max # At least 1 hour

      # Message frequency (messages per hour)
      frequency = messages.count / time_span

      # Average message length
      avg_length = messages.sum { |m| m.content.length } / messages.count.to_f

      # Question rate (messages with ?)
      question_count = messages.count { |m| m.content.include?('?') }
      question_rate = question_count.to_f / messages.count

      # First person usage rate
      first_person_count = messages.count { |m| m.content.match?(/\b(i|my|me|i'm)\b/i) }
      first_person_rate = first_person_count.to_f / messages.count

      # Determine engagement level
      level = if frequency >= ENGAGEMENT_INDICATORS[:high_engagement][:message_frequency] &&
                  avg_length >= ENGAGEMENT_INDICATORS[:high_engagement][:avg_message_length]
                :high
              elsif frequency < 2 || avg_length < 20
                :low
              else
                :medium
              end

      {
        level: level,
        metrics: {
          message_frequency: frequency.round(2),
          avg_message_length: avg_length.round(1),
          question_rate: question_rate.round(2),
          first_person_rate: first_person_rate.round(2)
        }
      }
    end

    def detect_preferences(messages, actions)
      preferences = {}

      # Prefer detailed descriptions?
      detail_keywords = ENGAGEMENT_INDICATORS[:exploration_depth][:detail_keywords]
      detail_usage = messages.count { |m| detail_keywords.any? { |kw| m.content.downcase.include?(kw) } }
      preferences[:detailed_descriptions] = detail_usage > messages.count * 0.2

      # Prefer tactical information?
      tactical_keywords = INTENT_PATTERNS[:tactical][:keywords]
      tactical_usage = messages.count { |m| tactical_keywords.any? { |kw| m.content.downcase.include?(kw) } }
      preferences[:tactical_details] = tactical_usage > messages.count * 0.15

      # Prefer dialogue/RP?
      rp_keywords = INTENT_PATTERNS[:roleplay_focused][:keywords]
      rp_usage = messages.count { |m| rp_keywords.any? { |kw| m.content.downcase.include?(kw) } }
      preferences[:roleplay_heavy] = rp_usage > messages.count * 0.3

      # Quick actions vs detailed messages?
      preferences[:prefers_quick_actions] = messages.all? { |m| m.content.length < 50 }

      preferences
    end

    def determine_primary_intent(scores)
      return nil if scores.empty?
      scores.max_by { |_intent, score| score }&.first
    end

    def determine_secondary_intent(scores)
      return nil if scores.count < 2

      sorted = scores.sort_by { |_intent, score| -score }
      sorted[1]&.first
    end

    def generate_recommendations(intent_scores, engagement, preferences)
      recommendations = []

      # Intent-based recommendations
      primary = determine_primary_intent(intent_scores)

      case primary
      when :combat_focused
        recommendations << "Focus on tactical combat encounters"
        recommendations << "Provide strategic challenges" if preferences[:tactical_details]
      when :roleplay_focused
        recommendations << "Emphasize NPC interactions and social challenges"
        recommendations << "Create opportunities for character expression"
      when :exploration_focused
        recommendations << "Describe environments with explorable details"
        recommendations << "Hide secrets and discoveries for investigation"
      when :story_focused
        recommendations << "Develop plot hooks and narrative threads"
        recommendations << "Connect events to larger story arcs"
      when :loot_focused
        recommendations << "Ensure regular treasure and item discoveries"
        recommendations << "Describe valuable items with flavor"
      end

      # Engagement-based recommendations
      case engagement[:level]
      when :high
        recommendations << "Maintain current engagement with varied content"
      when :low
        recommendations << "Add hooks to recapture engagement"
        recommendations << "Try personal stakes or mysteries"
      end

      # Preference-based recommendations
      if preferences[:detailed_descriptions]
        recommendations << "Provide rich, detailed environmental descriptions"
      end

      if preferences[:tactical_details]
        recommendations << "Include tactical information (distances, cover, positioning)"
      end

      if preferences[:prefers_quick_actions]
        recommendations << "Offer quick action buttons for common choices"
      end

      recommendations.uniq
    end

    def calculate_confidence(message_count)
      case message_count
      when 0..4
        10 # Very low confidence
      when 5..10
        30 # Low confidence
      when 11..20
        60 # Medium confidence
      when 21..30
        85 # High confidence
      else
        95 # Very high confidence
      end
    end

    def minimal_analysis
      {
        primary_intent: nil,
        secondary_intent: nil,
        intent_scores: {},
        engagement: { level: :unknown, metrics: {} },
        preferences: {},
        recommendations: ["Not enough data yet - continue playing to build player profile"],
        confidence: 10,
        message_count: 0,
        action_count: 0
      }
    end

    # Class method for campaign-wide intent analysis
    def self.campaign_summary(campaign)
      sessions = TerminalSession.where(campaign: campaign).where.not(character_id: nil)
      analyses = sessions.map { |session| new(session).analyze }

      # Aggregate intent scores
      aggregated_intents = {}
      INTENT_PATTERNS.keys.each do |intent|
        scores = analyses.map { |a| a[:intent_scores][intent] || 0.0 }
        aggregated_intents[intent] = (scores.sum / scores.count.to_f).round(2) if scores.any?
      end

      # Average engagement
      engagement_levels = analyses.map { |a| a[:engagement][:level] }.compact
      avg_engagement = engagement_levels.group_by(&:itself).transform_values(&:count)

      {
        session_count: sessions.count,
        average_intents: aggregated_intents,
        engagement_distribution: avg_engagement,
        primary_campaign_intent: aggregated_intents.max_by { |_, score| score }&.first,
        total_messages: analyses.sum { |a| a[:message_count] }
      }
    end
  end
end
