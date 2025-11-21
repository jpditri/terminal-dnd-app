# frozen_string_literal: true

module Content
  # Analyzes content pacing to prevent overwhelming players
  # Tracks balance between combat, social, and exploration content
  # Provides guidance to AI DM for better pacing
  class PacingAnalyzer
    LOOKBACK_HOURS = 2 # Analyze last 2 hours of gameplay
    LOOKBACK_ACTIONS = 20 # Or last 20 actions, whichever comes first

    # Content type classification based on tool categories
    CONTENT_TYPES = {
      combat: %i[combat],
      social: %i[npc dialogue social],
      exploration: %i[quest discovery exploration environment],
      character: %i[character],
      utility: %i[utility system]
    }.freeze

    # Healthy distribution targets (percentages)
    HEALTHY_DISTRIBUTION = {
      combat: 0.30,      # 30% combat
      social: 0.30,      # 30% social
      exploration: 0.25, # 25% exploration
      character: 0.10,   # 10% character management
      utility: 0.05      # 5% utility/system
    }.freeze

    # Thresholds for warnings
    EXCESSIVE_THRESHOLD = 0.50 # Warn if any type exceeds 50%
    LACKING_THRESHOLD = 0.10   # Warn if any main type below 10%

    attr_reader :session, :character

    def initialize(terminal_session)
      @session = terminal_session
      @character = session.character
    end

    # Get comprehensive pacing analysis
    def analyze
      recent_actions = fetch_recent_actions
      distribution = calculate_distribution(recent_actions)
      recommendations = generate_recommendations(distribution)

      {
        summary: generate_summary(distribution),
        distribution: distribution,
        total_actions: recent_actions.count,
        timeframe: determine_timeframe(recent_actions),
        recommendations: recommendations,
        pacing_score: calculate_pacing_score(distribution),
        warnings: generate_warnings(distribution)
      }
    end

    # Get quick pacing guidance for AI DM context
    def dm_context_message
      analysis = analyze
      return nil if analysis[:total_actions] < 5 # Not enough data

      messages = []

      # Add warnings
      messages.concat(analysis[:warnings]) if analysis[:warnings].any?

      # Add top recommendation
      if analysis[:recommendations].any?
        messages << analysis[:recommendations].first
      end

      messages.join(' ')
    end

    # Check if specific content type should be avoided
    def should_avoid?(content_type)
      distribution = calculate_distribution(fetch_recent_actions)
      return false unless distribution[content_type]

      distribution[content_type][:percentage] > EXCESSIVE_THRESHOLD
    end

    # Get suggested content type to balance pacing
    def suggested_content_type
      distribution = calculate_distribution(fetch_recent_actions)

      # Find which main type is most lacking
      main_types = %i[combat social exploration]
      lacking = main_types.min_by do |type|
        distribution[type]&.dig(:percentage) || 0.0
      end

      lacking
    end

    private

    def fetch_recent_actions
      cutoff_time = LOOKBACK_HOURS.hours.ago

      DmActionAuditLog
        .where(terminal_session: session)
        .where(execution_status: 'executed')
        .where('created_at >= ?', cutoff_time)
        .order(created_at: :desc)
        .limit(LOOKBACK_ACTIONS)
        .to_a
        .reverse # Chronological order
    end

    def calculate_distribution(actions)
      return {} if actions.empty?

      # Classify each action
      classified = actions.group_by { |action| classify_action(action) }

      # Calculate counts and percentages
      total = actions.count.to_f
      distribution = {}

      CONTENT_TYPES.keys.each do |type|
        type_actions = classified[type] || []
        count = type_actions.count

        distribution[type] = {
          count: count,
          percentage: count / total,
          recent_count: type_actions.last(5).count # Last 5 actions
        }
      end

      distribution
    end

    def classify_action(action)
      tool_category = get_tool_category(action.tool_name)

      # Map category to content type
      CONTENT_TYPES.each do |content_type, categories|
        return content_type if categories.include?(tool_category)
      end

      :utility # Default
    end

    def get_tool_category(tool_name)
      # Lookup tool category from ToolRegistry
      tool_def = AiDm::ToolRegistry::TOOLS[tool_name.to_sym]
      return tool_def[:category] if tool_def

      # Fallback classification based on tool name
      case tool_name.to_s
      when /combat|attack|damage|initiative/i
        :combat
      when /npc|spawn|talk|persuade|dialogue/i
        :npc
      when /quest|discover|search|investigate/i
        :quest
      when /character|level|ability|skill/i
        :character
      else
        :utility
      end
    end

    def generate_summary(distribution)
      return 'Not enough data for pacing analysis' if distribution.empty?

      # Find dominant type
      dominant = distribution.max_by { |_type, data| data[:percentage] }
      dominant_type = dominant[0]
      dominant_pct = (dominant[1][:percentage] * 100).round

      "Content distribution: #{dominant_pct}% #{dominant_type}, pacing score #{calculate_pacing_score(distribution)}/100"
    end

    def calculate_pacing_score(distribution)
      return 50 if distribution.empty? # Neutral score

      # Calculate deviation from healthy distribution
      total_deviation = CONTENT_TYPES.keys.sum do |type|
        actual = distribution[type]&.dig(:percentage) || 0.0
        target = HEALTHY_DISTRIBUTION[type] || 0.0
        (actual - target).abs
      end

      # Convert to 0-100 score (lower deviation = higher score)
      # Perfect balance = 0 deviation = 100 score
      # Maximum reasonable deviation = 2.0 (200%) = 0 score
      score = [100 - (total_deviation * 50), 0].max.round

      score
    end

    def generate_recommendations(distribution)
      return [] if distribution.empty?

      recommendations = []

      # Check for imbalances
      main_types = %i[combat social exploration]

      main_types.each do |type|
        data = distribution[type]
        next unless data

        pct = data[:percentage]
        target = HEALTHY_DISTRIBUTION[type]

        if pct > EXCESSIVE_THRESHOLD
          recommendations << "Reduce #{type} content (currently #{(pct * 100).round}%)"
        elsif pct < LACKING_THRESHOLD && data[:count] > 0
          recommendations << "Add more #{type} content (only #{(pct * 100).round}%)"
        end
      end

      # Check for recent clustering
      distribution.each do |type, data|
        if data[:recent_count] >= 4 && type != :utility
          recommendations << "Recent #{type} clustering detected - vary content"
        end
      end

      recommendations
    end

    def generate_warnings(distribution)
      return [] if distribution.empty?

      warnings = []

      %i[combat social exploration].each do |type|
        data = distribution[type]
        next unless data

        if data[:percentage] > EXCESSIVE_THRESHOLD
          warnings << "⚠️  Excessive #{type} (#{(data[:percentage] * 100).round}%) - players may feel overwhelmed"
        end
      end

      warnings
    end

    def determine_timeframe(actions)
      return 'No actions' if actions.empty?

      oldest = actions.first.created_at
      newest = actions.last.created_at
      minutes = ((newest - oldest) / 60).round

      if minutes < 60
        "#{minutes} minutes"
      else
        hours = (minutes / 60.0).round(1)
        "#{hours} hours"
      end
    end

    # Class method for campaign-wide analysis
    def self.campaign_summary(campaign)
      sessions = TerminalSession.where(campaign: campaign)
      analyses = sessions.map { |session| new(session).analyze }

      {
        session_count: sessions.count,
        average_pacing_score: analyses.map { |a| a[:pacing_score] }.sum / sessions.count.to_f,
        common_issues: find_common_issues(analyses)
      }
    end

    def self.find_common_issues(analyses)
      all_warnings = analyses.flat_map { |a| a[:warnings] }
      all_warnings.group_by(&:itself).transform_values(&:count).sort_by { |_, count| -count }.first(3).to_h
    end
  end
end
