# frozen_string_literal: true

module Narrative
  # Tracks narrative arcs and story structure across campaign
  # Manages multiple concurrent story threads, pacing, and dramatic structure
  # Provides context to AI DM about narrative state and progression
  class ArcTracker
    attr_reader :campaign

    # Arc phases based on classic story structure
    ARC_PHASES = {
      setup: { order: 1, description: 'Introducing the conflict or goal' },
      rising_action: { order: 2, description: 'Building tension and stakes' },
      climax: { order: 3, description: 'Peak of conflict and drama' },
      falling_action: { order: 4, description: 'Consequences and resolution beginning' },
      resolution: { order: 5, description: 'Conclusion and aftermath' }
    }.freeze

    # Arc types for different story threads
    ARC_TYPES = {
      main_plot: { priority: 5, description: 'Primary campaign storyline' },
      character_arc: { priority: 4, description: 'Personal character development' },
      side_quest: { priority: 3, description: 'Optional story thread' },
      faction_conflict: { priority: 4, description: 'Faction-driven storyline' },
      mystery: { priority: 3, description: 'Investigation or puzzle thread' },
      romance: { priority: 2, description: 'Relationship development' },
      world_event: { priority: 3, description: 'World-changing event' }
    }.freeze

    # Pacing recommendations
    PACING_STATES = {
      stagnant: 'No recent arc progression - introduce new developments',
      slow: 'Minimal progression - consider escalating stakes',
      steady: 'Good pacing - maintain current rhythm',
      fast: 'Rapid progression - allow breathing room',
      rushed: 'Too much happening - focus and consolidate'
    }.freeze

    def initialize(campaign)
      @campaign = campaign
    end

    # Create a new narrative arc
    def create_arc(title:, arc_type:, phase: :setup, description: nil, metadata: {})
      return { success: false, error: 'Invalid arc type' } unless ARC_TYPES.key?(arc_type.to_sym)
      return { success: false, error: 'Invalid phase' } unless ARC_PHASES.key?(phase.to_sym)

      arc_data = {
        id: SecureRandom.uuid,
        title: title,
        arc_type: arc_type,
        phase: phase,
        description: description,
        created_at: Time.current.iso8601,
        last_updated: Time.current.iso8601,
        status: 'active',
        metadata: metadata,
        beats: []
      }

      current_state = campaign.world_state || {}
      arcs = current_state['narrative_arcs'] || []
      arcs << arc_data

      campaign.update!(
        world_state: current_state.merge('narrative_arcs' => arcs)
      )

      { success: true, arc: arc_data }
    end

    # Record a story beat (significant narrative event)
    def record_beat(arc_id:, beat_title:, beat_type: :event, description: nil, metadata: {})
      arc = find_arc(arc_id)
      return { success: false, error: 'Arc not found' } unless arc

      beat_data = {
        id: SecureRandom.uuid,
        title: beat_title,
        beat_type: beat_type,
        description: description,
        recorded_at: Time.current.iso8601,
        metadata: metadata
      }

      arc['beats'] << beat_data
      arc['last_updated'] = Time.current.iso8601

      update_arc(arc)

      { success: true, beat: beat_data, arc_id: arc_id }
    end

    # Progress arc to next phase
    def advance_phase(arc_id, reason: nil)
      arc = find_arc(arc_id)
      return { success: false, error: 'Arc not found' } unless arc

      current_phase = arc['phase'].to_sym
      phase_order = ARC_PHASES.keys

      current_index = phase_order.index(current_phase)
      return { success: false, error: 'Arc already at final phase' } if current_index >= phase_order.length - 1

      new_phase = phase_order[current_index + 1]
      old_phase = current_phase

      arc['phase'] = new_phase
      arc['last_updated'] = Time.current.iso8601

      # Record phase transition as beat
      record_beat(
        arc_id: arc_id,
        beat_title: "Phase Transition: #{old_phase} → #{new_phase}",
        beat_type: :phase_change,
        description: reason
      )

      update_arc(arc)

      {
        success: true,
        arc_id: arc_id,
        old_phase: old_phase,
        new_phase: new_phase,
        phase_description: ARC_PHASES[new_phase][:description]
      }
    end

    # Complete/resolve an arc
    def complete_arc(arc_id, resolution: nil)
      arc = find_arc(arc_id)
      return { success: false, error: 'Arc not found' } unless arc

      arc['status'] = 'completed'
      arc['completed_at'] = Time.current.iso8601
      arc['resolution'] = resolution if resolution
      arc['last_updated'] = Time.current.iso8601

      update_arc(arc)

      { success: true, arc_id: arc_id, title: arc['title'] }
    end

    # Get all active arcs
    def active_arcs
      all_arcs.select { |arc| arc['status'] == 'active' }
    end

    # Get arcs by type
    def arcs_by_type(arc_type)
      all_arcs.select { |arc| arc['arc_type'] == arc_type.to_s }
    end

    # Get arcs by phase
    def arcs_by_phase(phase)
      all_arcs.select { |arc| arc['phase'] == phase.to_s }
    end

    # Get narrative pacing analysis
    def analyze_pacing
      arcs = active_arcs

      return { pacing: :stagnant, message: 'No active narrative arcs' } if arcs.empty?

      # Count recent beats across all arcs
      recent_beats = arcs.sum do |arc|
        arc['beats'].count { |beat| Time.parse(beat['recorded_at']) > 1.hour.ago }
      end

      # Count arcs that have advanced recently
      recent_advancement = arcs.count do |arc|
        Time.parse(arc['last_updated']) > 2.hours.ago
      end

      # Determine pacing state
      pacing = if recent_beats == 0 && recent_advancement == 0
        :stagnant
      elsif recent_beats <= 2 && recent_advancement <= 1
        :slow
      elsif recent_beats <= 5 && recent_advancement <= 3
        :steady
      elsif recent_beats <= 8
        :fast
      else
        :rushed
      end

      {
        pacing: pacing,
        message: PACING_STATES[pacing],
        recent_beats: recent_beats,
        recent_advancement: recent_advancement,
        active_arc_count: arcs.count
      }
    end

    # Get DM context message about narrative state
    def dm_context_message
      arcs = active_arcs
      return nil if arcs.empty?

      pacing_analysis = analyze_pacing

      # Group arcs by priority
      high_priority = arcs.select { |arc| ARC_TYPES[arc['arc_type'].to_sym][:priority] >= 4 }

      return nil if high_priority.empty?

      arc_summaries = high_priority.map do |arc|
        beat_count = arc['beats'].count
        phase_desc = ARC_PHASES[arc['phase'].to_sym][:description]
        "  - **#{arc['title']}** (#{arc['arc_type'].humanize}): #{arc['phase'].humanize} - #{phase_desc} [#{beat_count} beats]"
      end

      <<~CONTEXT
        NARRATIVE ARCS:
        #{arc_summaries.join("\n")}

        Pacing: #{pacing_analysis[:pacing].to_s.upcase} - #{pacing_analysis[:message]}

        Consider narrative arcs when creating encounters and quests. Advance arcs through meaningful story beats.
      CONTEXT
    end

    # Get recommendations for narrative development
    def generate_recommendations
      recommendations = []
      arcs = active_arcs
      pacing = analyze_pacing

      # Pacing recommendations
      case pacing[:pacing]
      when :stagnant
        recommendations << "Introduce new story beats or advance existing arcs"
        recommendations << "Consider starting a new arc if all current arcs are resolved"
      when :slow
        recommendations << "Escalate stakes in at least one active arc"
        recommendations << "Introduce complications or twists"
      when :rushed
        recommendations << "Allow breathing room between major events"
        recommendations << "Focus on fewer arcs to avoid overwhelming players"
      end

      # Arc-specific recommendations
      arcs.each do |arc|
        phase = arc['phase'].to_sym
        beats = arc['beats'].count

        case phase
        when :setup
          if beats > 3
            recommendations << "#{arc['title']}: Ready to transition to Rising Action"
          end
        when :rising_action
          if beats > 5
            recommendations << "#{arc['title']}: Consider approaching Climax"
          end
        when :climax
          if beats > 2
            recommendations << "#{arc['title']}: Move toward resolution"
          end
        when :falling_action, :resolution
          if beats > 3
            recommendations << "#{arc['title']}: Ready to complete this arc"
          end
        end
      end

      # Check for arc diversity
      arc_types = arcs.map { |arc| arc['arc_type'] }.uniq
      if arc_types.count == 1 && arcs.count > 2
        recommendations << "All active arcs are #{arc_types.first} - consider introducing different arc type for variety"
      end

      recommendations
    end

    # Get summary of all arcs
    def summary
      arcs = all_arcs
      active = active_arcs

      {
        total_arcs: arcs.count,
        active_arcs: active.count,
        completed_arcs: arcs.count { |arc| arc['status'] == 'completed' },
        arcs_by_type: arcs.group_by { |arc| arc['arc_type'] }.transform_values(&:count),
        arcs_by_phase: active.group_by { |arc| arc['phase'] }.transform_values(&:count),
        total_beats: arcs.sum { |arc| arc['beats'].count },
        pacing: analyze_pacing,
        recommendations: generate_recommendations
      }
    end

    # Class method for campaign-wide analysis
    def self.campaign_analysis(campaign)
      tracker = new(campaign)
      summary = tracker.summary

      {
        campaign_id: campaign.id,
        campaign_name: campaign.name,
        narrative_summary: summary,
        most_advanced_arcs: tracker.active_arcs
          .select { |arc| arc['beats'].count >= 3 }
          .sort_by { |arc| arc['beats'].count }
          .reverse
          .first(3)
          .map { |arc| { title: arc['title'], phase: arc['phase'], beats: arc['beats'].count } }
      }
    end

    private

    def all_arcs
      current_state = campaign.world_state || {}
      current_state['narrative_arcs'] || []
    end

    def find_arc(arc_id)
      all_arcs.find { |arc| arc['id'] == arc_id }
    end

    def update_arc(updated_arc)
      current_state = campaign.world_state || {}
      arcs = current_state['narrative_arcs'] || []

      # Replace old arc with updated version
      arcs.map! { |arc| arc['id'] == updated_arc['id'] ? updated_arc : arc }

      campaign.update!(
        world_state: current_state.merge(
          'narrative_arcs' => arcs,
          'last_updated' => Time.current.iso8601
        )
      )
    end
  end
end
