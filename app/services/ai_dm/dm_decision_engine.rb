# frozen_string_literal: true

module AiDm
  # DmDecisionEngine provides smart decision-making for dynamic NPC spawning
  # Analyzes context, narrative flow, and game state to determine when and what NPCs to spawn
  class DmDecisionEngine
    attr_reader :session, :character, :campaign

    # Thresholds for spawn decisions
    NPC_DENSITY_LOW = 0
    NPC_DENSITY_MEDIUM = 2
    NPC_DENSITY_HIGH = 5

    SCENE_LONELINESS_THRESHOLD = 3 # Turns without NPC interaction

    def initialize(terminal_session)
      @session = terminal_session
      @character = session.character
      @campaign = session.campaign
    end

    # Main decision method: Should we spawn an NPC now?
    def should_spawn_npc?(context = {})
      return false unless campaign

      # Collect all spawn factors
      factors = analyze_spawn_factors(context)

      # Calculate spawn probability (0.0 to 1.0)
      spawn_probability = calculate_spawn_probability(factors)

      # Make weighted random decision
      decision = rand < spawn_probability

      {
        should_spawn: decision,
        probability: spawn_probability,
        factors: factors,
        reasoning: generate_reasoning(factors, decision)
      }
    end

    # Determine what type of NPC to spawn based on context
    def determine_npc_type(context = {})
      location_type = classify_location(context[:location])
      narrative_tone = analyze_narrative_tone(context)
      party_needs = assess_party_needs

      # Score different NPC types
      type_scores = {
        'guard' => 0,
        'merchant' => 0,
        'innkeeper' => 0,
        'priest' => 0,
        'thug' => 0,
        'noble' => 0,
        'scout' => 0,
        'mage' => 0,
        'bandit' => 0,
        'blacksmith' => 0
      }

      # Location-based scoring
      type_scores.merge!(score_by_location(location_type))

      # Narrative tone adjustments
      type_scores.merge!(score_by_narrative(narrative_tone))

      # Party needs adjustments
      type_scores.merge!(score_by_needs(party_needs))

      # Select highest scoring type with some randomness
      select_weighted_type(type_scores)
    end

    # Determine NPC disposition based on context
    def determine_disposition(context = {})
      location_danger = assess_location_danger(context[:location])
      recent_combat = has_recent_combat?
      character_reputation = assess_reputation

      # Base disposition weights
      disposition_weights = {
        'friendly' => 40,
        'neutral' => 50,
        'hostile' => 10
      }

      # Adjust based on danger level
      case location_danger
      when :high
        disposition_weights['hostile'] += 30
        disposition_weights['friendly'] -= 20
      when :medium
        disposition_weights['hostile'] += 10
        disposition_weights['neutral'] += 10
      when :low
        disposition_weights['friendly'] += 20
        disposition_weights['hostile'] -= 10
      end

      # Adjust based on recent combat
      if recent_combat
        disposition_weights['hostile'] += 20
        disposition_weights['friendly'] -= 10
      end

      # Adjust based on reputation
      case character_reputation
      when :heroic
        disposition_weights['friendly'] += 25
        disposition_weights['hostile'] -= 15
      when :infamous
        disposition_weights['hostile'] += 25
        disposition_weights['friendly'] -= 15
      end

      # Normalize and select
      select_weighted_disposition(disposition_weights)
    end

    # Generate spawn recommendations
    def generate_spawn_recommendation(context = {})
      decision = should_spawn_npc?(context)

      return { recommended: false, reasoning: decision[:reasoning] } unless decision[:should_spawn]

      npc_type = determine_npc_type(context)
      disposition = determine_disposition(context)

      {
        recommended: true,
        npc_type: npc_type,
        disposition: disposition,
        importance_level: determine_importance_level(context),
        suggested_name: generate_name_suggestion(npc_type),
        spawn_method: determine_spawn_method(context),
        reasoning: decision[:reasoning],
        spawn_probability: decision[:probability]
      }
    end

    # Check if scene is appropriate for NPC spawn
    def scene_appropriate_for_npc?(scene_description)
      # Scenes where NPCs make sense
      appropriate_keywords = [
        'town', 'city', 'village', 'tavern', 'inn', 'shop', 'market',
        'road', 'path', 'gate', 'entrance', 'temple', 'church',
        'camp', 'settlement', 'outpost', 'fortress'
      ]

      # Scenes where NPCs are unlikely
      inappropriate_keywords = [
        'wilderness', 'deep forest', 'mountain peak', 'cave depths',
        'underwater', 'void', 'empty', 'abandoned', 'ruins'
      ]

      scene_lower = scene_description.to_s.downcase

      has_appropriate = appropriate_keywords.any? { |kw| scene_lower.include?(kw) }
      has_inappropriate = inappropriate_keywords.any? { |kw| scene_lower.include?(kw) }

      has_appropriate && !has_inappropriate
    end

    private

    def analyze_spawn_factors(context)
      {
        scene_loneliness: calculate_scene_loneliness,
        npc_density: calculate_npc_density(context[:location]),
        narrative_momentum: assess_narrative_momentum,
        scene_appropriateness: scene_appropriate_for_npc?(context[:scene_description]) ? 1.0 : 0.0,
        player_engagement: assess_player_engagement,
        story_beats: count_story_beats_since_npc,
        location_type: classify_location(context[:location]),
        time_since_spawn: time_since_last_spawn,
        quest_pressure: assess_quest_presentation_pressure
      }
    end

    def calculate_spawn_probability(factors)
      probability = 0.0

      # Loneliness factor (0-0.4): More turns without NPCs = higher spawn chance
      if factors[:scene_loneliness] >= SCENE_LONELINESS_THRESHOLD
        probability += 0.3
      elsif factors[:scene_loneliness] > 0
        probability += 0.15
      end

      # NPC density factor (0-0.3): Fewer NPCs nearby = higher spawn chance
      case factors[:npc_density]
      when NPC_DENSITY_LOW
        probability += 0.3
      when NPC_DENSITY_MEDIUM
        probability += 0.15
      when NPC_DENSITY_HIGH
        probability += 0.0
      end

      # Scene appropriateness (0-0.4): Right location = much higher chance
      probability += 0.4 * factors[:scene_appropriateness]

      # Narrative momentum (0-0.2): Low momentum = spawn NPC to drive story
      case factors[:narrative_momentum]
      when :stalled
        probability += 0.2
      when :slow
        probability += 0.1
      when :steady, :fast
        probability += 0.0
      end

      # Story beats (-0.2 to +0.1): Too many recent NPCs = lower chance
      if factors[:story_beats] > 2
        probability -= 0.2
      elsif factors[:story_beats] == 0
        probability += 0.1
      end

      # Time since last spawn (+0.1): Long time = slight bonus
      probability += 0.1 if factors[:time_since_spawn] > 10

      # Quest pressure (-0.3 to +0.0): Heavily penalize if quests are being ignored
      case factors[:quest_pressure]
      when :excessive
        probability -= 0.3 # Player is clearly avoiding quests - stop spawning quest NPCs
      when :high
        probability -= 0.15 # Multiple ignored quests - reduce quest NPC spawns
      when :moderate
        probability -= 0.05 # Some ignored quests - slight reduction
      when :low, :none
        probability += 0.0 # Normal quest engagement
      end

      # Clamp between 0 and 1
      probability.clamp(0.0, 1.0)
    end

    def calculate_scene_loneliness
      # Count narrative outputs since last NPC interaction
      recent_npc_outputs = session.narrative_outputs
                                  .where('created_at > ?', 10.minutes.ago)
                                  .where('content ILIKE ? OR speaker IS NOT NULL', '%NPC%')
                                  .count

      recent_npc_outputs.zero? ? 5 : [3 - recent_npc_outputs, 0].max
    end

    def calculate_npc_density(location)
      return NPC_DENSITY_LOW unless location

      # Count NPCs in current location
      nearby_npcs = Npc.for_campaign(campaign)
                       .where('location_id IS NOT NULL')
                       .count

      case nearby_npcs
      when 0..1 then NPC_DENSITY_LOW
      when 2..4 then NPC_DENSITY_MEDIUM
      else NPC_DENSITY_HIGH
      end
    end

    def assess_narrative_momentum
      recent_narratives = session.narrative_outputs.where('created_at > ?', 5.minutes.ago).count

      case recent_narratives
      when 0..2 then :stalled
      when 3..5 then :slow
      when 6..10 then :steady
      else :fast
      end
    end

    def assess_player_engagement
      # Check narrative frequency (approximating player activity via narrative outputs)
      recent_outputs = session.narrative_outputs
                              .where('created_at > ?', 10.minutes.ago)
                              .count

      recent_outputs > 3 ? :high : :low
    end

    def count_story_beats_since_npc
      # Count significant events since last NPC spawn
      recent_npcs = Npc.for_campaign(campaign)
                       .where('created_at > ?', 15.minutes.ago)
                       .count

      recent_npcs
    end

    def time_since_last_spawn
      last_npc = Npc.for_campaign(campaign).order(created_at: :desc).first
      return 999 unless last_npc

      ((Time.current - last_npc.created_at) / 60).to_i # Minutes
    end

    def classify_location(location_name)
      return :unknown unless location_name

      location_lower = location_name.downcase

      case location_lower
      when /town|city|village/ then :settlement
      when /tavern|inn/ then :social_hub
      when /shop|market|store/ then :commercial
      when /temple|church|shrine/ then :religious
      when /road|path|trail/ then :travel
      when /forest|woods|wilderness/ then :wilderness
      when /dungeon|cave|ruins/ then :dungeon
      when /castle|fortress|keep/ then :fortification
      else :unknown
      end
    end

    def analyze_narrative_tone(context)
      recent_content = context[:recent_narrative] || ''
      content_lower = recent_content.downcase

      return :combat if content_lower.match?(/attack|fight|battle|wound/)
      return :mystery if content_lower.match?(/investigate|clue|suspect|mysterious/)
      return :social if content_lower.match?(/talk|negotiate|persuade|conversation/)
      return :exploration if content_lower.match?(/discover|explore|find|search/)

      :neutral
    end

    def assess_party_needs
      needs = []

      # Check character health
      if character && character.hit_points_current && character.hit_points_max
        if character.hit_points_current < (character.hit_points_max * 0.5)
          needs << :healing
        end
      end

      # Check inventory
      # needs << :equipment if character.inventory_items.count < 3

      # Check quest status
      active_quests = QuestLog.where(campaign: campaign, status: 'active').count
      needs << :quest_giver if active_quests.zero?

      needs
    end

    def assess_location_danger(location_name)
      return :medium unless location_name

      location_lower = location_name.downcase

      case location_lower
      when /dungeon|cave|ruins|wilderness|forest|mountain/ then :high
      when /road|path|outskirts/ then :medium
      when /town|city|village|tavern|inn|temple/ then :low
      else :medium
      end
    end

    def has_recent_combat?
      # Check for recent combat in narrative outputs
      session.narrative_outputs
             .where('created_at > ?', 5.minutes.ago)
             .where('content ILIKE ?', '%combat%')
             .exists?
    end

    def assess_reputation
      # Simple reputation assessment based on completed quests
      completed_quests = QuestLog.where(campaign: campaign, status: 'completed').count

      case completed_quests
      when 0..2 then :unknown
      when 3..5 then :known
      when 6..10 then :heroic
      else :legendary
      end
    end

    def score_by_location(location_type)
      scores = Hash.new(0)

      case location_type
      when :settlement
        scores.merge!('merchant' => 20, 'guard' => 15, 'noble' => 10)
      when :social_hub
        scores.merge!('innkeeper' => 30, 'merchant' => 10, 'guard' => 5)
      when :commercial
        scores.merge!('merchant' => 40, 'blacksmith' => 20)
      when :religious
        scores.merge!('priest' => 50, 'noble' => 10)
      when :travel
        scores.merge!('scout' => 25, 'bandit' => 15, 'merchant' => 10)
      when :wilderness
        scores.merge!('scout' => 30, 'bandit' => 20)
      when :dungeon
        scores.merge!('scout' => 15, 'mage' => 10)
      when :fortification
        scores.merge!('guard' => 40, 'noble' => 15)
      end

      scores
    end

    def score_by_narrative(narrative_tone)
      scores = Hash.new(0)

      case narrative_tone
      when :combat
        scores.merge!('guard' => 15, 'thug' => 10, 'scout' => 10)
      when :mystery
        scores.merge!('mage' => 15, 'noble' => 10, 'priest' => 10)
      when :social
        scores.merge!('merchant' => 15, 'innkeeper' => 15, 'noble' => 10)
      when :exploration
        scores.merge!('scout' => 20, 'merchant' => 10)
      end

      scores
    end

    def score_by_needs(needs)
      scores = Hash.new(0)

      needs.each do |need|
        case need
        when :healing
          scores['priest'] += 25
        when :equipment
          scores['merchant'] += 20
          scores['blacksmith'] += 20
        when :quest_giver
          scores['noble'] += 15
          scores['priest'] += 10
        end
      end

      scores
    end

    def select_weighted_type(type_scores)
      total_weight = type_scores.values.sum + 10 # Base weight for randomness
      return 'guard' if total_weight.zero?

      random_value = rand(total_weight)
      cumulative = 0

      type_scores.each do |type, score|
        cumulative += score
        return type if random_value < cumulative
      end

      type_scores.keys.sample || 'guard'
    end

    def select_weighted_disposition(weights)
      total = weights.values.sum
      return 'neutral' if total.zero?

      random_value = rand(total)
      cumulative = 0

      weights.each do |disposition, weight|
        cumulative += weight
        return disposition if random_value < cumulative
      end

      'neutral'
    end

    def determine_importance_level(context)
      # Check if this is a major story moment
      major_keywords = context[:scene_description].to_s.downcase

      return 'major' if major_keywords.match?(/important|crucial|key|essential/)
      return 'minor' if major_keywords.match?(/passing|brief|momentary/)

      'normal'
    end

    def generate_name_suggestion(npc_type)
      # Simple name generation based on type
      first_names = %w[Aldric Bran Cedric Dana Elara Finn Gwen Holt Iris Jax]
      last_names = %w[Stone Wood Iron Swift Bright Dark Strong Wise Bold Fair]

      "#{first_names.sample} #{last_names.sample}"
    end

    def determine_spawn_method(context)
      location_type = classify_location(context[:location])

      case location_type
      when :settlement, :social_hub, :commercial, :religious, :fortification
        :scene_entry
      when :travel, :wilderness
        :random_encounter
      when :dungeon
        :random_encounter
      else
        :narrative
      end
    end

    def assess_quest_presentation_pressure
      # Analyze quest state using ConsequenceManager to determine if we're over-presenting quests
      ignored_quests = QuestLog
        .where(campaign: campaign)
        .where(status: %w[active available])
        .select { |quest| Quest::ConsequenceManager.new(quest).should_present_again? == false }
        .size

      # Quests with high presentation count but not accepted
      over_presented = QuestLog
        .where(campaign: campaign)
        .where(status: %w[available])
        .where('presentation_count >= ?', Quest::ConsequenceManager::IGNORE_THRESHOLD)
        .count

      case
      when ignored_quests >= 3 || over_presented >= 2
        :excessive # Player is clearly avoiding quests
      when ignored_quests >= 2 || over_presented >= 1
        :high # Multiple ignored quests
      when ignored_quests == 1
        :moderate # One ignored quest
      else
        :none # Normal quest engagement
      end
    end

    def generate_reasoning(factors, decision)
      reasons = []

      if factors[:scene_loneliness] >= SCENE_LONELINESS_THRESHOLD
        reasons << "Scene has been quiet for #{factors[:scene_loneliness]} turns"
      end

      case factors[:npc_density]
      when NPC_DENSITY_LOW
        reasons << "Low NPC density in area"
      when NPC_DENSITY_HIGH
        reasons << "Area already has many NPCs"
      end

      if factors[:scene_appropriateness] > 0.5
        reasons << "Scene is appropriate for NPC encounter"
      elsif factors[:scene_appropriateness] < 0.3
        reasons << "Scene is isolated or inappropriate for NPCs"
      end

      case factors[:narrative_momentum]
      when :stalled
        reasons << "Narrative momentum has stalled - NPC could drive story"
      when :fast
        reasons << "Narrative is moving quickly - NPC might slow it down"
      end

      case factors[:quest_pressure]
      when :excessive
        reasons << "Player has ignored multiple quests - avoiding quest NPCs"
      when :high
        reasons << "Some quests have been ignored - reducing quest NPC spawns"
      end

      if decision
        "Recommend spawning NPC: #{reasons.join(', ')}"
      else
        "Do not recommend spawning NPC: #{reasons.join(', ')}"
      end
    end
  end
end
