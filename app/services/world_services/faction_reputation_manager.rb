# frozen_string_literal: true

module WorldServices
  # Manages faction reputation and relationships with characters
  # Tracks how player actions affect standing with different factions
  # Provides context to AI DM about faction attitudes
  class FactionReputationManager
    attr_reader :campaign

    # Reputation levels and thresholds
    REPUTATION_LEVELS = {
      revered: { min: 75, label: 'Revered', description: 'Hero of the faction' },
      honored: { min: 50, label: 'Honored', description: 'Highly respected' },
      friendly: { min: 25, label: 'Friendly', description: 'Well-liked' },
      neutral: { min: -24, label: 'Neutral', description: 'No strong opinion' },
      unfriendly: { min: -49, label: 'Unfriendly', description: 'Distrusted' },
      hostile: { min: -74, label: 'Hostile', description: 'Actively opposed' },
      hated: { min: -100, label: 'Hated', description: 'Kill on sight' }
    }.freeze

    def initialize(campaign)
      @campaign = campaign
    end

    # Adjust reputation with a faction
    def adjust_reputation(faction_id:, character:, amount:, reason: nil)
      faction = Faction.find(faction_id)
      current_rep = get_reputation(faction_id, character)
      new_rep = [[current_rep + amount, -100].max, 100].min # Clamp between -100 and 100

      # Store in campaign world_state
      store_reputation(faction_id, character, new_rep)

      # Record the change in history
      record_reputation_change(
        faction: faction,
        character: character,
        old_value: current_rep,
        new_value: new_rep,
        amount: amount,
        reason: reason
      )

      # Check for level transitions
      old_level = reputation_level(current_rep)
      new_level = reputation_level(new_rep)

      if old_level != new_level
        handle_reputation_level_change(faction, character, old_level, new_level)
      end

      {
        faction_id: faction_id,
        faction_name: faction.name,
        old_reputation: current_rep,
        new_reputation: new_rep,
        change: amount,
        level: new_level,
        level_changed: old_level != new_level
      }
    end

    # Get current reputation with a faction
    def get_reputation(faction_id, character)
      reputation_data = get_reputation_data
      key = reputation_key(faction_id, character)
      reputation_data[key] || 0
    end

    # Get reputation level label
    def get_reputation_level(faction_id, character)
      rep = get_reputation(faction_id, character)
      level = reputation_level(rep)
      REPUTATION_LEVELS[level][:label]
    end

    # Get all faction reputations for a character
    def character_reputations(character)
      reputation_data = get_reputation_data
      prefix = "char_#{character.id}_"

      reputation_data.select { |k, _v| k.start_with?(prefix) }.map do |key, value|
        faction_id = key.split('_').last.to_i
        faction = Faction.find_by(id: faction_id)
        next unless faction

        {
          faction_id: faction.id,
          faction_name: faction.name,
          reputation: value,
          level: reputation_level(value),
          level_label: REPUTATION_LEVELS[reputation_level(value)][:label]
        }
      end.compact
    end

    # Get faction attitudes summary
    def faction_attitudes_summary(character)
      reps = character_reputations(character)
      return nil if reps.empty?

      allies = reps.select { |r| r[:level] == :friendly || r[:level] == :honored || r[:level] == :revered }
      enemies = reps.select { |r| r[:level] == :hostile || r[:level] == :hated }
      neutral = reps.select { |r| r[:level] == :neutral }

      <<~SUMMARY
        Faction Standing:
        - Allies: #{allies.map { |r| r[:faction_name] }.join(', ').presence || 'None'}
        - Enemies: #{enemies.map { |r| r[:faction_name] }.join(', ').presence || 'None'}
        - Neutral: #{neutral.count} factions
      SUMMARY
    end

    # Get DM context message about faction relationships
    def dm_context_message(character)
      reps = character_reputations(character)
      return nil if reps.empty?

      notable = reps.select do |r|
        [:revered, :honored, :hostile, :hated].include?(r[:level])
      end

      return nil if notable.empty?

      messages = notable.map do |r|
        attitude = r[:level] == :revered || r[:level] == :honored ? 'ally' : 'enemy'
        "#{r[:faction_name]} (#{attitude})"
      end

      "Faction relationships: #{messages.join(', ')}"
    end

    # Check if faction is allied with character
    def is_allied?(faction_id, character)
      rep = get_reputation(faction_id, character)
      reputation_level(rep) == :friendly || reputation_level(rep) == :honored || reputation_level(rep) == :revered
    end

    # Check if faction is hostile to character
    def is_hostile?(faction_id, character)
      rep = get_reputation(faction_id, character)
      reputation_level(rep) == :hostile || reputation_level(rep) == :hated
    end

    # Get reputation change history
    def reputation_history(faction_id, character, limit: 10)
      current_state = campaign.world_state || {}
      history = current_state['reputation_history'] || []

      key = reputation_key(faction_id, character)
      history.select { |h| h['key'] == key }.last(limit).reverse
    end

    # Predict faction reaction to an action
    def predict_reaction(faction_id, action_type)
      # Hook for future AI-driven faction reaction prediction
      # For now, return basic reactions
      case action_type
      when :help_member
        { reputation_change: +10, description: 'Faction appreciates your help' }
      when :harm_member
        { reputation_change: -20, description: 'Faction is angered' }
      when :complete_quest
        { reputation_change: +15, description: 'Faction respects your dedication' }
      when :fail_quest
        { reputation_change: -10, description: 'Faction is disappointed' }
      else
        { reputation_change: 0, description: 'No significant impact' }
      end
    end

    private

    def reputation_key(faction_id, character)
      "char_#{character.id}_faction_#{faction_id}"
    end

    def get_reputation_data
      current_state = campaign.world_state || {}
      current_state['faction_reputations'] || {}
    end

    def store_reputation(faction_id, character, value)
      current_state = campaign.world_state || {}
      reputation_data = current_state['faction_reputations'] || {}

      key = reputation_key(faction_id, character)
      reputation_data[key] = value

      campaign.update!(
        world_state: current_state.merge(
          'faction_reputations' => reputation_data,
          'last_updated' => Time.current.iso8601
        )
      )
    end

    def record_reputation_change(faction:, character:, old_value:, new_value:, amount:, reason:)
      current_state = campaign.world_state || {}
      history = current_state['reputation_history'] || []

      change_record = {
        'key' => reputation_key(faction.id, character),
        'faction_id' => faction.id,
        'faction_name' => faction.name,
        'character_id' => character.id,
        'character_name' => character.name,
        'old_value' => old_value,
        'new_value' => new_value,
        'change' => amount,
        'reason' => reason,
        'old_level' => reputation_level(old_value),
        'new_level' => reputation_level(new_value),
        'recorded_at' => Time.current.iso8601
      }

      history << change_record

      # Keep last 200 changes
      history = history.last(200)

      campaign.update!(
        world_state: current_state.merge('reputation_history' => history)
      )
    end

    def reputation_level(value)
      REPUTATION_LEVELS.each do |level, config|
        return level if value >= config[:min]
      end
      :hated # Fallback
    end

    def handle_reputation_level_change(faction, character, old_level, new_level)
      # Record in world state tracker
      state_tracker = WorldServices::StateTracker.new(campaign)

      if better_standing?(old_level, new_level)
        state_tracker.record_event(
          event_type: :faction_allied,
          description: "#{character.name} gained standing with #{faction.name} (now #{REPUTATION_LEVELS[new_level][:label]})",
          severity: new_level == :revered ? :major : :moderate,
          metadata: {
            faction_id: faction.id,
            character_id: character.id,
            old_level: old_level,
            new_level: new_level
          }
        )
      else
        state_tracker.record_event(
          event_type: :faction_hostile,
          description: "#{character.name} lost standing with #{faction.name} (now #{REPUTATION_LEVELS[new_level][:label]})",
          severity: new_level == :hated ? :major : :moderate,
          metadata: {
            faction_id: faction.id,
            character_id: character.id,
            old_level: old_level,
            new_level: new_level
          }
        )
      end
    end

    def better_standing?(old_level, new_level)
      level_order = [:hated, :hostile, :unfriendly, :neutral, :friendly, :honored, :revered]
      level_order.index(new_level) > level_order.index(old_level)
    end
  end
end
