# frozen_string_literal: true

module AiDm
  # TreasureDecisionEngine provides smart decision-making for dynamic treasure generation
  # Analyzes context, player wealth, challenge rating, and game balance to determine when and what treasure to grant
  class TreasureDecisionEngine
    attr_reader :session, :character, :campaign

    # Treasure appropriateness thresholds
    WEALTH_RATIO_POOR = 0.5      # Below 50% of expected wealth
    WEALTH_RATIO_NORMAL = 1.0    # At expected wealth for level
    WEALTH_RATIO_WEALTHY = 1.5   # 50% above expected wealth

    # Expected wealth by level (D&D 5e guidelines in gold pieces)
    EXPECTED_WEALTH_BY_LEVEL = {
      1 => 100,
      2 => 200,
      3 => 400,
      4 => 800,
      5 => 2000,
      6 => 4000,
      7 => 8000,
      8 => 16_000,
      9 => 32_000,
      10 => 64_000,
      11 => 128_000,
      12 => 256_000,
      13 => 512_000,
      14 => 1_024_000,
      15 => 2_048_000,
      16 => 4_096_000,
      17 => 8_192_000,
      18 => 16_384_000,
      19 => 32_768_000,
      20 => 65_536_000
    }.freeze

    # Time thresholds
    TIME_SINCE_LAST_TREASURE_THRESHOLD = 15 # minutes

    def initialize(terminal_session)
      @session = terminal_session
      @character = session.character
      @campaign = session.campaign
    end

    # Main decision method: Should we grant treasure now?
    def should_grant_treasure?(context = {})
      return false unless campaign && character

      # Collect all treasure grant factors
      factors = analyze_treasure_factors(context)

      # Calculate treasure probability (0.0 to 1.0)
      treasure_probability = calculate_treasure_probability(factors)

      # Make weighted random decision
      decision = rand < treasure_probability

      {
        should_grant: decision,
        probability: treasure_probability,
        factors: factors,
        reasoning: generate_reasoning(factors, decision)
      }
    end

    # Determine what type of treasure to grant based on context
    def determine_treasure_type(context = {})
      challenge_rating = context[:challenge_rating] || estimate_challenge_rating(context)
      location_type = classify_location(context[:location])
      recent_combat = context[:after_combat] || false

      # Score different treasure types
      type_scores = {
        'gold' => 0,
        'magic_item' => 0,
        'consumable' => 0,
        'equipment' => 0,
        'art_object' => 0,
        'gemstone' => 0,
        'trade_good' => 0
      }

      # Location-based scoring
      type_scores.merge!(score_by_location(location_type))

      # Combat-based scoring
      type_scores.merge!(score_by_combat(recent_combat, challenge_rating))

      # Wealth-based adjustments
      type_scores.merge!(score_by_wealth_level)

      # Select highest scoring type with some randomness
      select_weighted_type(type_scores)
    end

    # Determine treasure value/rarity based on context
    def determine_treasure_value(context = {})
      challenge_rating = context[:challenge_rating] || estimate_challenge_rating(context)
      wealth_ratio = calculate_wealth_ratio
      location_danger = assess_location_danger(context[:location])

      # Base value from CR
      base_value = calculate_base_value_from_cr(challenge_rating)

      # Adjust based on wealth ratio
      base_value *= 1.5 if wealth_ratio < WEALTH_RATIO_POOR
      base_value *= 0.7 if wealth_ratio > WEALTH_RATIO_WEALTHY

      # Adjust based on location danger
      case location_danger
      when :high
        base_value *= 1.3
      when :medium
        base_value *= 1.0
      when :low
        base_value *= 0.8
      end

      # Add randomness (±30%)
      variance = 0.7 + (rand * 0.6)
      final_value = (base_value * variance).to_i

      {
        gold_value: final_value,
        rarity: determine_rarity(final_value),
        suggested_description: generate_treasure_description(final_value, context)
      }
    end

    # Generate comprehensive treasure recommendation
    def generate_treasure_recommendation(context = {})
      decision = should_grant_treasure?(context)

      return { recommended: false, reasoning: decision[:reasoning] } unless decision[:should_grant]

      treasure_type = determine_treasure_type(context)
      treasure_value = determine_treasure_value(context)

      {
        recommended: true,
        treasure_type: treasure_type,
        gold_value: treasure_value[:gold_value],
        rarity: treasure_value[:rarity],
        description: treasure_value[:suggested_description],
        reasoning: decision[:reasoning],
        grant_probability: decision[:probability]
      }
    end

    # Check if context is appropriate for treasure
    def context_appropriate_for_treasure?(context)
      # Combat should have ended
      return true if context[:after_combat]

      # Exploration context
      scene_description = context[:scene_description].to_s.downcase
      appropriate_keywords = [
        'chest', 'treasure', 'hoard', 'vault', 'cache',
        'defeated', 'victory', 'corpse', 'body',
        'hidden', 'secret', 'discovered', 'found'
      ]

      appropriate_keywords.any? { |kw| scene_description.include?(kw) }
    end

    private

    def analyze_treasure_factors(context)
      {
        wealth_ratio: calculate_wealth_ratio,
        time_since_treasure: time_since_last_treasure,
        combat_victory: context[:after_combat] || false,
        challenge_rating: context[:challenge_rating] || estimate_challenge_rating(context),
        location_danger: assess_location_danger(context[:location]),
        context_appropriateness: context_appropriate_for_treasure?(context) ? 1.0 : 0.0,
        treasure_frequency: assess_treasure_frequency,
        player_engagement: assess_player_engagement,
        narrative_reward: context[:narrative_reward] || false
      }
    end

    def calculate_treasure_probability(factors)
      probability = 0.0

      # Wealth ratio factor (0-0.3): Poor = higher treasure chance
      if factors[:wealth_ratio] < WEALTH_RATIO_POOR
        probability += 0.3
      elsif factors[:wealth_ratio] < WEALTH_RATIO_NORMAL
        probability += 0.15
      elsif factors[:wealth_ratio] > WEALTH_RATIO_WEALTHY
        probability -= 0.2
      end

      # Combat victory (0-0.4): Major factor for treasure
      if factors[:combat_victory]
        cr = factors[:challenge_rating]
        case cr
        when 0..2
          probability += 0.2
        when 3..5
          probability += 0.3
        else
          probability += 0.4
        end
      end

      # Context appropriateness (0-0.3): Right situation = higher chance
      probability += 0.3 * factors[:context_appropriateness]

      # Time since last treasure (0-0.2): Long time = bonus
      if factors[:time_since_treasure] > TIME_SINCE_LAST_TREASURE_THRESHOLD
        probability += 0.2
      elsif factors[:time_since_treasure] < 5
        probability -= 0.1
      end

      # Treasure frequency (-0.3 to +0.1): Too frequent = reduce
      case factors[:treasure_frequency]
      when :excessive
        probability -= 0.3
      when :high
        probability -= 0.15
      when :low
        probability += 0.1
      when :normal
        probability += 0.0
      end

      # Location danger (0-0.2): Dangerous = more reward
      case factors[:location_danger]
      when :high
        probability += 0.2
      when :medium
        probability += 0.1
      when :low
        probability += 0.0
      end

      # Narrative reward (0-0.3): Explicit reward moment
      probability += 0.3 if factors[:narrative_reward]

      # Clamp between 0 and 1
      probability.clamp(0.0, 1.0)
    end

    def calculate_wealth_ratio
      return 1.0 unless character && character.level

      expected_wealth = EXPECTED_WEALTH_BY_LEVEL[character.level] || 100
      current_wealth = character.gold || 0

      (current_wealth.to_f / expected_wealth).round(2)
    end

    def time_since_last_treasure
      # Check when last treasure was granted via audit logs
      last_treasure = DmActionAuditLog
        .where(terminal_session: session)
        .where(tool_name: %w[grant_item generate_treasure grant_gold])
        .where(execution_status: 'executed')
        .order(created_at: :desc)
        .first

      return 999 unless last_treasure

      ((Time.current - last_treasure.created_at) / 60).to_i # Minutes
    end

    def estimate_challenge_rating(context)
      # If we have a combat difficulty context, use that
      return context[:enemy_cr].to_i if context[:enemy_cr]

      # Otherwise estimate from character level
      return 0 unless character

      # Appropriate CR is roughly equal to character level
      character.level
    end

    def classify_location(location_name)
      return :unknown unless location_name

      location_lower = location_name.downcase

      case location_lower
      when /town|city|village/ then :settlement
      when /tavern|inn/ then :social_hub
      when /shop|market|store/ then :commercial
      when /temple|church|shrine/ then :religious
      when /dungeon|cave|ruins/ then :dungeon
      when /castle|fortress|keep/ then :fortification
      when /wilderness|forest|mountain/ then :wilderness
      when /road|path|trail/ then :travel
      else :unknown
      end
    end

    def assess_location_danger(location_name)
      return :medium unless location_name

      location_lower = location_name.downcase

      case location_lower
      when /dungeon|cave|ruins|wilderness|deep|dark/ then :high
      when /road|path|outskirts|forest/ then :medium
      when /town|city|village|tavern|inn|temple/ then :low
      else :medium
      end
    end

    def assess_treasure_frequency
      # Count treasure grants in last hour
      recent_treasure = DmActionAuditLog
        .where(terminal_session: session)
        .where(tool_name: %w[grant_item generate_treasure grant_gold])
        .where(execution_status: 'executed')
        .where('created_at > ?', 1.hour.ago)
        .count

      case recent_treasure
      when 0..1 then :low
      when 2..3 then :normal
      when 4..5 then :high
      else :excessive
      end
    end

    def assess_player_engagement
      recent_outputs = session.narrative_outputs
                              .where('created_at > ?', 10.minutes.ago)
                              .count

      recent_outputs > 3 ? :high : :low
    end

    def score_by_location(location_type)
      scores = Hash.new(0)

      case location_type
      when :dungeon
        scores.merge!('gold' => 25, 'magic_item' => 20, 'art_object' => 15, 'gemstone' => 15)
      when :fortification
        scores.merge!('equipment' => 25, 'gold' => 20, 'art_object' => 10)
      when :wilderness
        scores.merge!('trade_good' => 20, 'consumable' => 15, 'gold' => 10)
      when :settlement
        scores.merge!('gold' => 30, 'trade_good' => 20, 'equipment' => 10)
      when :religious
        scores.merge!('art_object' => 25, 'gold' => 20, 'magic_item' => 15)
      when :commercial
        scores.merge!('gold' => 40, 'trade_good' => 25)
      else
        scores.merge!('gold' => 20, 'consumable' => 10)
      end

      scores
    end

    def score_by_combat(recent_combat, challenge_rating)
      scores = Hash.new(0)

      return scores unless recent_combat

      # Combat victory typically yields treasure
      scores['gold'] += 20
      scores['equipment'] += 15
      scores['consumable'] += 10

      # Higher CR enemies drop better loot
      if challenge_rating >= 5
        scores['magic_item'] += 25
        scores['art_object'] += 15
      elsif challenge_rating >= 3
        scores['magic_item'] += 10
        scores['gemstone'] += 15
      end

      scores
    end

    def score_by_wealth_level
      scores = Hash.new(0)
      wealth_ratio = calculate_wealth_ratio

      # If player is poor, favor gold
      if wealth_ratio < WEALTH_RATIO_POOR
        scores['gold'] += 30
        scores['gemstone'] += 15
      elsif wealth_ratio > WEALTH_RATIO_WEALTHY
        # If wealthy, favor interesting items over gold
        scores['magic_item'] += 25
        scores['art_object'] += 20
        scores['gold'] -= 20
      end

      scores
    end

    def calculate_base_value_from_cr(challenge_rating)
      # Base treasure value scales with CR
      case challenge_rating
      when 0 then 10
      when 1 then 25
      when 2 then 50
      when 3 then 100
      when 4 then 200
      when 5 then 400
      when 6..7 then 800
      when 8..10 then 1600
      when 11..13 then 3200
      when 14..16 then 6400
      when 17..20 then 12_800
      else 25_600
      end
    end

    def determine_rarity(gold_value)
      case gold_value
      when 0..50 then 'common'
      when 51..250 then 'uncommon'
      when 251..1000 then 'rare'
      when 1001..5000 then 'very_rare'
      else 'legendary'
      end
    end

    def generate_treasure_description(value, context)
      rarity = determine_rarity(value)

      descriptions = {
        'common' => 'A modest collection',
        'uncommon' => 'A respectable reward',
        'rare' => 'An impressive haul',
        'very_rare' => 'A remarkable treasure',
        'legendary' => 'An extraordinary fortune'
      }

      descriptions[rarity] || 'Some treasure'
    end

    def select_weighted_type(type_scores)
      total_weight = type_scores.values.sum + 10 # Base weight for randomness
      return 'gold' if total_weight.zero?

      random_value = rand(total_weight)
      cumulative = 0

      type_scores.each do |type, score|
        cumulative += score
        return type if random_value < cumulative
      end

      type_scores.keys.sample || 'gold'
    end

    def generate_reasoning(factors, decision)
      reasons = []

      # Wealth status
      if factors[:wealth_ratio] < WEALTH_RATIO_POOR
        reasons << "Character wealth below expected (#{(factors[:wealth_ratio] * 100).to_i}% of level-appropriate)"
      elsif factors[:wealth_ratio] > WEALTH_RATIO_WEALTHY
        reasons << "Character already wealthy (#{(factors[:wealth_ratio] * 100).to_i}% of level-appropriate)"
      end

      # Combat victory
      if factors[:combat_victory]
        cr_text = factors[:challenge_rating] > 0 ? " (CR #{factors[:challenge_rating]})" : ''
        reasons << "Victory in combat#{cr_text} warrants reward"
      end

      # Time since last treasure
      if factors[:time_since_treasure] > TIME_SINCE_LAST_TREASURE_THRESHOLD
        reasons << "#{factors[:time_since_treasure]} minutes since last treasure"
      elsif factors[:time_since_treasure] < 5
        reasons << "Treasure granted recently (#{factors[:time_since_treasure]} min ago)"
      end

      # Treasure frequency
      case factors[:treasure_frequency]
      when :excessive
        reasons << "Treasure being granted too frequently - reducing spawn rate"
      when :high
        reasons << "Treasure frequency above normal"
      when :low
        reasons << "Low treasure frequency - can increase"
      end

      # Context appropriateness
      if factors[:context_appropriateness] > 0.5
        reasons << "Context appropriate for treasure discovery"
      elsif factors[:context_appropriateness] < 0.3
        reasons << "Context not well-suited for treasure"
      end

      # Location danger
      if factors[:location_danger] == :high
        reasons << "Dangerous location warrants greater reward"
      end

      if decision
        "Recommend granting treasure: #{reasons.join(', ')}"
      else
        "Do not recommend treasure: #{reasons.join(', ')}"
      end
    end
  end
end
