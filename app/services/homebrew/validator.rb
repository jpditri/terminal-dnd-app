# frozen_string_literal: true

module Homebrew
  # Validates homebrew content against D&D 5e standards
  # Ensures balance, proper formatting, and adherence to game rules
  class Validator
    VALID_RARITIES = %w[common uncommon rare very_rare legendary artifact].freeze
    VALID_ITEM_TYPES = %w[weapon armor potion scroll wand staff ring wondrous].freeze
    VALID_DAMAGE_TYPES = %w[acid bludgeoning cold fire force lightning necrotic piercing poison psychic radiant slashing thunder].freeze
    VALID_ABILITY_SCORES = %w[strength dexterity constitution intelligence wisdom charisma].freeze

    # Rarity-based balance guidelines
    RARITY_GUIDELINES = {
      'common' => {
        max_bonus: 1,
        requires_attunement: false,
        max_spell_level: 1,
        max_daily_uses: 3,
        max_ac_bonus: 1,
        max_ability_bonus: 1
      },
      'uncommon' => {
        max_bonus: 1,
        requires_attunement: false,
        max_spell_level: 3,
        max_daily_uses: 3,
        max_ac_bonus: 1,
        max_ability_bonus: 2
      },
      'rare' => {
        max_bonus: 2,
        requires_attunement: true,
        max_spell_level: 6,
        max_daily_uses: 5,
        max_ac_bonus: 2,
        max_ability_bonus: 2
      },
      'very_rare' => {
        max_bonus: 3,
        requires_attunement: true,
        max_spell_level: 8,
        max_daily_uses: 7,
        max_ac_bonus: 3,
        max_ability_bonus: 4
      },
      'legendary' => {
        max_bonus: 3,
        requires_attunement: true,
        max_spell_level: 9,
        max_daily_uses: 10,
        max_ac_bonus: 3,
        max_ability_bonus: 6
      },
      'artifact' => {
        max_bonus: 5,
        requires_attunement: true,
        max_spell_level: 9,
        max_daily_uses: 999,
        max_ac_bonus: 5,
        max_ability_bonus: 10
      }
    }.freeze

    attr_reader :errors, :warnings

    def initialize
      @errors = []
      @warnings = []
    end

    # Validate a homebrew item
    # @param item_data [Hash] Item data to validate
    # @return [Boolean] true if valid (may have warnings)
    def validate_item(item_data)
      reset_validation_state

      validate_required_fields(item_data)
      validate_rarity(item_data[:rarity])
      validate_item_type(item_data[:item_type])
      validate_properties(item_data[:properties], item_data[:rarity])
      validate_attunement(item_data[:requires_attunement], item_data[:attunement_requirements], item_data[:rarity])
      validate_description(item_data[:description])

      @errors.empty?
    end

    # Validate a homebrew spell
    # @param spell_data [Hash] Spell data to validate
    # @return [Boolean] true if valid
    def validate_spell(spell_data)
      reset_validation_state

      validate_spell_required_fields(spell_data)
      validate_spell_level(spell_data[:level])
      validate_spell_school(spell_data[:school])
      validate_spell_components(spell_data[:components])
      validate_spell_range(spell_data[:range])
      validate_spell_duration(spell_data[:duration])

      @errors.empty?
    end

    # Get validation results
    # @return [Hash] Validation summary
    def validation_result
      {
        valid: @errors.empty?,
        errors: @errors,
        warnings: @warnings,
        message: validation_message
      }
    end

    private

    def reset_validation_state
      @errors = []
      @warnings = []
    end

    def validate_required_fields(item_data)
      required_fields = [:name, :description, :rarity, :item_type]

      required_fields.each do |field|
        if item_data[field].blank?
          @errors << "Missing required field: #{field}"
        end
      end
    end

    def validate_rarity(rarity)
      return if rarity.blank? # Caught by required_fields

      unless VALID_RARITIES.include?(rarity.to_s)
        @errors << "Invalid rarity: #{rarity}. Must be one of: #{VALID_RARITIES.join(', ')}"
      end
    end

    def validate_item_type(item_type)
      return if item_type.blank? # Caught by required_fields

      unless VALID_ITEM_TYPES.include?(item_type.to_s)
        @errors << "Invalid item type: #{item_type}. Must be one of: #{VALID_ITEM_TYPES.join(', ')}"
      end
    end

    def validate_properties(properties, rarity)
      return if properties.blank?

      guidelines = RARITY_GUIDELINES[rarity.to_s]
      return unless guidelines

      # Validate damage bonus
      if properties[:damage_bonus].present?
        validate_damage_bonus(properties[:damage_bonus], guidelines[:max_bonus], rarity)
      end

      # Validate AC bonus
      if properties[:ac_bonus].present?
        validate_ac_bonus(properties[:ac_bonus], guidelines[:max_ac_bonus], rarity)
      end

      # Validate ability score bonuses
      if properties[:ability_bonuses].present?
        validate_ability_bonuses(properties[:ability_bonuses], guidelines[:max_ability_bonus], rarity)
      end

      # Validate spell effects
      if properties[:spell_effects].present?
        validate_spell_effects(properties[:spell_effects], guidelines[:max_spell_level], rarity)
      end

      # Validate daily uses
      if properties[:daily_uses].present?
        validate_daily_uses(properties[:daily_uses], guidelines[:max_daily_uses], rarity)
      end

      # Validate damage dice
      if properties[:damage_dice].present?
        validate_damage_dice(properties[:damage_dice])
      end

      # Validate damage type
      if properties[:damage_type].present?
        validate_damage_type(properties[:damage_type])
      end
    end

    def validate_damage_bonus(bonus, max_bonus, rarity)
      bonus_value = bonus.to_i

      if bonus_value > max_bonus
        @warnings << "Damage bonus +#{bonus_value} exceeds recommended maximum +#{max_bonus} for #{rarity} items"
      elsif bonus_value < 0
        @errors << "Damage bonus cannot be negative"
      end
    end

    def validate_ac_bonus(bonus, max_ac_bonus, rarity)
      bonus_value = bonus.to_i

      if bonus_value > max_ac_bonus
        @warnings << "AC bonus +#{bonus_value} exceeds recommended maximum +#{max_ac_bonus} for #{rarity} items"
      elsif bonus_value < 0
        @errors << "AC bonus cannot be negative"
      end
    end

    def validate_ability_bonuses(bonuses, max_bonus, rarity)
      bonuses.each do |ability, bonus|
        unless VALID_ABILITY_SCORES.include?(ability.to_s)
          @errors << "Invalid ability score: #{ability}. Must be one of: #{VALID_ABILITY_SCORES.join(', ')}"
        end

        bonus_value = bonus.to_i
        if bonus_value > max_bonus
          @warnings << "#{ability.capitalize} bonus +#{bonus_value} exceeds recommended maximum +#{max_bonus} for #{rarity} items"
        elsif bonus_value < 0
          @errors << "Ability bonuses cannot be negative"
        end
      end
    end

    def validate_spell_effects(spell_effects, max_spell_level, rarity)
      spell_effects.each do |effect|
        spell_level = effect[:level] || effect['level']

        if spell_level.present? && spell_level.to_i > max_spell_level
          @warnings << "Spell level #{spell_level} exceeds recommended maximum #{max_spell_level} for #{rarity} items"
        end

        if effect[:spell_name].blank? && effect['spell_name'].blank?
          @errors << "Spell effect missing spell_name"
        end
      end
    end

    def validate_daily_uses(uses, max_daily_uses, rarity)
      uses_value = uses.to_i

      if uses_value > max_daily_uses && rarity != 'artifact'
        @warnings << "Daily uses #{uses_value} exceeds recommended maximum #{max_daily_uses} for #{rarity} items"
      elsif uses_value < 1
        @errors << "Daily uses must be at least 1"
      end
    end

    def validate_damage_dice(damage_dice)
      # Validate dice expression format
      unless damage_dice.match?(/^\d+d\d+(\+\d+)?$/i)
        @errors << "Invalid damage dice format: #{damage_dice}. Expected format: XdY or XdY+Z (e.g., 2d6+3)"
      end

      # Try to parse it
      begin
        Treasure::DiceParser.roll(damage_dice)
      rescue Treasure::DiceParser::InvalidDiceExpression => e
        @errors << "Invalid damage dice: #{e.message}"
      end
    end

    def validate_damage_type(damage_type)
      unless VALID_DAMAGE_TYPES.include?(damage_type.to_s)
        @errors << "Invalid damage type: #{damage_type}. Must be one of: #{VALID_DAMAGE_TYPES.join(', ')}"
      end
    end

    def validate_attunement(requires_attunement, attunement_requirements, rarity)
      guidelines = RARITY_GUIDELINES[rarity.to_s]
      return unless guidelines

      # Warn if rare+ item doesn't require attunement (unusual)
      if %w[rare very_rare legendary].include?(rarity.to_s) && !requires_attunement
        @warnings << "#{rarity.capitalize} items typically require attunement for balance"
      end

      # Validate attunement requirements if present
      if requires_attunement && attunement_requirements.present?
        validate_attunement_requirements(attunement_requirements)
      end
    end

    def validate_attunement_requirements(requirements)
      # Check for class requirements
      if requirements[:classes].present? && requirements[:classes].empty?
        @warnings << "Attunement has empty classes array - remove if not restricting by class"
      end

      # Check for alignment requirements
      if requirements[:alignment].present?
        valid_alignments = %w[lawful_good neutral_good chaotic_good lawful_neutral true_neutral chaotic_neutral lawful_evil neutral_evil chaotic_evil]
        unless valid_alignments.include?(requirements[:alignment].to_s)
          @errors << "Invalid alignment: #{requirements[:alignment]}"
        end
      end
    end

    def validate_description(description)
      return if description.blank? # Caught by required_fields

      if description.length < 20
        @warnings << "Description is very short (#{description.length} characters). Consider adding more detail."
      end

      if description.length > 5000
        @warnings << "Description is very long (#{description.length} characters). Consider being more concise."
      end
    end

    # Spell validation methods

    def validate_spell_required_fields(spell_data)
      required_fields = [:name, :description, :level, :school, :casting_time, :range, :components, :duration]

      required_fields.each do |field|
        if spell_data[field].blank?
          @errors << "Missing required spell field: #{field}"
        end
      end
    end

    def validate_spell_level(level)
      return if level.blank?

      level_value = level.to_i
      unless (0..9).include?(level_value)
        @errors << "Invalid spell level: #{level}. Must be 0-9 (0 for cantrips)"
      end
    end

    def validate_spell_school(school)
      valid_schools = %w[abjuration conjuration divination enchantment evocation illusion necromancy transmutation]

      return if school.blank?

      unless valid_schools.include?(school.to_s.downcase)
        @errors << "Invalid spell school: #{school}. Must be one of: #{valid_schools.join(', ')}"
      end
    end

    def validate_spell_components(components)
      return if components.blank?

      valid_components = %w[V S M]
      component_array = components.is_a?(Array) ? components : [components]

      component_array.each do |component|
        unless valid_components.include?(component.to_s.upcase)
          @errors << "Invalid spell component: #{component}. Must be V (verbal), S (somatic), or M (material)"
        end
      end
    end

    def validate_spell_range(range)
      return if range.blank?

      # Valid ranges: Self, Touch, 30 feet, 1 mile, Sight, etc.
      valid_patterns = [
        /^self$/i,
        /^touch$/i,
        /^\d+\s+(feet|foot|miles?|kilometers?)$/i,
        /^sight$/i,
        /^unlimited$/i
      ]

      unless valid_patterns.any? { |pattern| range.to_s.match?(pattern) }
        @warnings << "Unusual spell range: #{range}. Standard ranges: Self, Touch, X feet, Sight, Unlimited"
      end
    end

    def validate_spell_duration(duration)
      return if duration.blank?

      # Valid durations: Instantaneous, 1 minute, Concentration up to 1 hour, etc.
      valid_patterns = [
        /^instantaneous$/i,
        /^concentration,?\s+up to\s+\d+\s+(rounds?|minutes?|hours?|days?)$/i,
        /^\d+\s+(rounds?|minutes?|hours?|days?)$/i,
        /^until dispelled$/i,
        /^special$/i
      ]

      unless valid_patterns.any? { |pattern| duration.to_s.match?(pattern) }
        @warnings << "Unusual spell duration: #{duration}. Standard: Instantaneous, X minutes/hours, Concentration up to X"
      end
    end

    def validation_message
      return "Validation passed successfully" if @errors.empty? && @warnings.empty?
      return "Validation passed with #{@warnings.count} warnings" if @errors.empty?
      "Validation failed with #{@errors.count} errors and #{@warnings.count} warnings"
    end
  end
end
