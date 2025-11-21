# frozen_string_literal: true

module WorldServices
  # Tracks persistent world state and consequences across sessions
  # Records major events, NPC deaths, faction changes, location changes
  # Provides context to AI DM about world state and history
  class StateTracker
    attr_reader :campaign

    # Event types that trigger world state updates
    EVENT_TYPES = {
      npc_death: 'NPC was killed',
      npc_recruited: 'NPC joined the party',
      npc_betrayed: 'NPC betrayed the party',
      faction_allied: 'Faction became ally',
      faction_hostile: 'Faction became hostile',
      location_destroyed: 'Location was destroyed',
      location_liberated: 'Location was liberated',
      quest_completed: 'Major quest completed',
      quest_failed: 'Major quest failed',
      item_obtained: 'Legendary item obtained',
      item_lost: 'Important item lost',
      secret_discovered: 'Major secret revealed',
      world_changed: 'Significant world change'
    }.freeze

    # Severity levels for events
    SEVERITY_LEVELS = {
      minor: 1,      # Small local impact
      moderate: 2,   # Affects a town or faction
      major: 3,      # Region-wide consequences
      critical: 4,   # World-changing event
      catastrophic: 5 # Apocalyptic consequences
    }.freeze

    def initialize(campaign)
      @campaign = campaign
    end

    # Record a world state event
    def record_event(event_type:, description:, severity: :moderate, metadata: {})
      return false unless EVENT_TYPES.key?(event_type)

      event_data = {
        event_type: event_type,
        description: description,
        severity: SEVERITY_LEVELS[severity] || 2,
        severity_label: severity,
        metadata: metadata,
        recorded_at: Time.current
      }

      # Store in campaign's world_state JSONB field
      current_state = campaign.world_state || {}
      events = current_state['events'] || []
      events << event_data

      # Keep last 100 events to prevent unbounded growth
      events = events.last(100)

      campaign.update!(
        world_state: current_state.merge(
          'events' => events,
          'last_updated' => Time.current.iso8601
        )
      )

      # Check if event triggers faction reputation changes
      process_faction_impacts(event_type, metadata)

      true
    end

    # Get recent world events
    def recent_events(limit: 10, min_severity: nil)
      events = all_events

      if min_severity
        severity_threshold = SEVERITY_LEVELS[min_severity] || 0
        events = events.select { |e| e['severity'] >= severity_threshold }
      end

      events.last(limit).reverse
    end

    # Get all recorded events
    def all_events
      current_state = campaign.world_state || {}
      current_state['events'] || []
    end

    # Get events by type
    def events_by_type(event_type)
      all_events.select { |e| e['event_type'].to_sym == event_type }
    end

    # Check if specific event has occurred
    def event_occurred?(event_type, match_metadata: {})
      events_by_type(event_type).any? do |event|
        match_metadata.all? do |key, value|
          event['metadata'][key.to_s] == value
        end
      end
    end

    # Get context message for AI DM
    def dm_context_message(limit: 5)
      events = recent_events(limit: limit, min_severity: :moderate)
      return nil if events.empty?

      messages = events.map do |event|
        severity_marker = severity_marker_for(event['severity'])
        "#{severity_marker} #{event['description']}"
      end

      <<~CONTEXT
        WORLD STATE:
        Recent significant events:
        #{messages.map { |m| "- #{m}" }.join("\n")}

        Consider these events when narrating and making decisions.
      CONTEXT
    end

    # Get world state summary
    def summary
      events = all_events
      return { total_events: 0, no_data: true } if events.empty?

      by_type = events.group_by { |e| e['event_type'] }.transform_values(&:count)
      by_severity = events.group_by { |e| e['severity'] }.transform_values(&:count)

      recent = recent_events(limit: 10)

      {
        total_events: events.count,
        events_by_type: by_type,
        events_by_severity: by_severity,
        most_recent: recent.first(3),
        most_severe: events.select { |e| e['severity'] >= 4 }.last(3).reverse,
        timeframe: determine_timeframe(events)
      }
    end

    # Clear old events (for cleanup/reset)
    def clear_old_events(days_old: 90)
      cutoff = days_old.days.ago
      current_state = campaign.world_state || {}
      events = current_state['events'] || []

      kept_events = events.select do |event|
        Time.parse(event['recorded_at']) > cutoff
      end

      campaign.update!(
        world_state: current_state.merge('events' => kept_events)
      )

      events.count - kept_events.count # Return number of events removed
    end

    # Record NPC death with faction implications
    def record_npc_death(npc, killer: nil, circumstances: nil)
      metadata = {
        npc_id: npc.id,
        npc_name: npc.name,
        faction_id: npc.faction_id,
        killer_type: killer&.class&.name,
        killer_id: killer&.id,
        circumstances: circumstances
      }

      severity = npc.faction_id.present? ? :major : :moderate

      record_event(
        event_type: :npc_death,
        description: "#{npc.name} was killed#{killer ? " by #{killer.try(:name) || 'unknown'}" : ''}",
        severity: severity,
        metadata: metadata
      )

      # If NPC had a faction, may impact faction relations
      if npc.faction_id.present? && killer.is_a?(Character)
        reputation_manager = WorldServices::FactionReputationManager.new(campaign)
        reputation_manager.adjust_reputation(
          faction_id: npc.faction_id,
          character: killer,
          amount: -20,
          reason: "Killed #{npc.name}"
        )
      end
    end

    # Record major quest outcome
    def record_quest_outcome(quest, outcome: :completed)
      event_type = outcome == :completed ? :quest_completed : :quest_failed
      severity = quest.difficulty == 'hard' ? :major : :moderate

      metadata = {
        quest_id: quest.id,
        quest_title: quest.title,
        quest_type: quest.quest_type,
        outcome: outcome
      }

      record_event(
        event_type: event_type,
        description: "#{outcome == :completed ? 'Completed' : 'Failed'} quest: #{quest.title}",
        severity: severity,
        metadata: metadata
      )
    end

    # Record faction relationship change
    def record_faction_change(faction, change_type:, description: nil)
      metadata = {
        faction_id: faction.id,
        faction_name: faction.name,
        change_type: change_type
      }

      event_type = change_type.to_sym
      severity = [:faction_allied, :faction_hostile].include?(event_type) ? :major : :moderate

      record_event(
        event_type: event_type,
        description: description || "Faction #{faction.name}: #{change_type.to_s.humanize}",
        severity: severity,
        metadata: metadata
      )
    end

    # Class method for campaign-wide analysis
    def self.campaign_analysis(campaign)
      tracker = new(campaign)
      summary = tracker.summary

      {
        campaign_id: campaign.id,
        campaign_name: campaign.name,
        total_events: summary[:total_events],
        major_events: summary[:most_severe]&.count || 0,
        event_types: summary[:events_by_type],
        recent_activity: summary[:most_recent]
      }
    end

    private

    def severity_marker_for(severity_level)
      case severity_level
      when 1 then '•'
      when 2 then '▪'
      when 3 then '▸'
      when 4 then '!'
      when 5 then '‼'
      else '·'
      end
    end

    def determine_timeframe(events)
      return 'No events' if events.empty?

      oldest = Time.parse(events.first['recorded_at'])
      newest = Time.parse(events.last['recorded_at'])
      days = ((newest - oldest) / 1.day).round

      if days < 1
        'Less than 1 day'
      elsif days < 7
        "#{days} days"
      elsif days < 30
        weeks = (days / 7.0).round
        "#{weeks} weeks"
      else
        months = (days / 30.0).round
        "#{months} months"
      end
    end

    def process_faction_impacts(event_type, metadata)
      # Hook for future faction impact processing
      # This could trigger reputation changes, faction reactions, etc.
      case event_type
      when :location_destroyed
        # Notify factions that control this location
      when :secret_discovered
        # Factions interested in this secret may react
      end
    end
  end
end
