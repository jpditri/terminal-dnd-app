# frozen_string_literal: true

module SoloPlay
  # Validates player actions against D&D 5e rules
  # Ported from heretical-web-app with adaptations for terminal-dnd
  #
  # Responsibilities:
  # - Validate action economy (action, bonus action, reaction)
  # - Enforce spell casting rules (bonus action + leveled spell restriction)
  # - Check movement constraints
  # - Validate resource availability (spell slots, class features)
  # - Check condition restrictions (incapacitated, impairing)
  class ActionValidator
    attr_reader :terminal_session

    # Incapacitating conditions that prevent all actions
    INCAPACITATING_CONDITIONS = %w[paralyzed stunned unconscious petrified].freeze

    # Conditions that impose disadvantage but don't prevent actions
    IMPAIRING_CONDITIONS = %w[poisoned frightened blinded restrained prone].freeze

    def initialize(terminal_session)
      raise ArgumentError, 'terminal_session is required' if terminal_session.nil?

      @terminal_session = terminal_session
    end

    # Validate any action against D&D 5e rules
    def validate_action(action_params)
      action_type = action_params[:action_type]
      errors = []
      warnings = []

      # Check if character is incapacitated
      if is_incapacitated?
        return {
          valid: false,
          errors: ['You cannot take actions while incapacitated (paralyzed, stunned, unconscious, or petrified).'],
          warnings: []
        }
      end

      # Add warnings for impairing conditions
      active_conditions = character&.conditions || []
      impairing = active_conditions & IMPAIRING_CONDITIONS
      if impairing.any?
        warnings << "You are #{impairing.join(', ')} - this may impose disadvantage on certain actions."
      end

      # Validate based on action type
      case action_type
      when 'attack', 'bonus_attack'
        result = validate_attack(action_params)
        errors.concat(result[:errors])
        warnings.concat(result[:warnings])
      when 'move'
        result = validate_movement(action_params)
        errors.concat(result[:errors])
      when 'cast_spell'
        result = validate_spell_cast(action_params)
        errors.concat(result[:errors])
        warnings.concat(result[:warnings])
      when 'use_feature'
        result = validate_feature_use(action_params)
        errors.concat(result[:errors])
      when 'opportunity_attack'
        result = validate_reaction(action_params)
        errors.concat(result[:errors])
      end

      # Check action economy
      action_cost = action_params[:requires] || determine_action_cost(action_type, action_params)
      unless can_take_action?(action_cost)
        case action_cost
        when 'action'
          errors << 'You have already used your action this turn.'
        when 'bonus_action'
          errors << 'You have already used your bonus action this turn.'
        when 'reaction'
          errors << 'You have already used your reaction this round.'
        end
      end

      {
        valid: errors.empty?,
        errors: errors,
        warnings: warnings
      }
    end

    # Validate attack actions
    def validate_attack(params)
      errors = []
      warnings = []

      weapon = params[:weapon]
      distance = params[:distance] || 5
      weapon_range = params[:weapon_range]

      # Melee attacks
      if weapon_range.nil? || weapon_range[:normal].nil? || weapon_range[:normal] <= 10
        if distance > 5
          errors << "Your #{weapon} is out of reach. Melee weapons can only attack targets within 5 feet."
        end
      else
        # Ranged attacks
        normal_range = weapon_range[:normal]
        long_range = weapon_range[:long]

        if distance > long_range
          errors << "Target is out of range. Your #{weapon} has a maximum range of #{long_range} feet."
        elsif distance > normal_range
          warnings << "Target is at long range (#{distance} ft). You have disadvantage on this attack roll."
        end
      end

      { valid: errors.empty?, errors: errors, warnings: warnings }
    end

    # Validate movement
    def validate_movement(params)
      errors = []
      distance = params[:distance] || 0
      current_movement = combat_tracker&.action_resources&.dig('current_turn_movement') || 0
      dashed = combat_tracker&.action_resources&.dig('current_turn_actions', 'dashed') || false

      max_movement = character&.speed || 30
      max_movement *= 2 if dashed

      total_movement = current_movement + distance

      if total_movement > max_movement
        remaining = max_movement - current_movement
        errors << "Moving #{distance} feet exceeds your movement speed. You have #{remaining} feet remaining (#{max_movement} feet total)."
      end

      { errors: errors }
    end

    # Validate spell casting (D&D 5e spell casting rules)
    def validate_spell_cast(params)
      errors = []
      warnings = []

      spell_level = params[:spell_level]
      spell_name = params[:spell_name]
      casting_time = params[:casting_time] || 'action'
      requires_concentration = params[:requires_concentration] || false

      # Cantrips don't use spell slots
      if spell_level > 0
        # Check spell slots FIRST before other validations
        unless has_spell_slot?(spell_level)
          errors << "You have no #{spell_level_name(spell_level)}-level spell slots remaining."
          return { errors: errors, warnings: warnings }
        end

        # D&D 5e Rule: Bonus action spell + action spell restriction
        current_turn_actions = combat_tracker&.action_resources&.dig('current_turn_actions') || {}

        if casting_time == 'bonus_action'
          # If casting bonus action spell, can only cast cantrip as action
          # This check needs to happen when NEXT spell is cast
        elsif current_turn_actions['bonus_action_spell_cast']
          errors << 'You can only cast a cantrip with your action after casting a spell as a bonus action.'
          return { errors: errors, warnings: warnings }
        end

        # Check if already cast a leveled spell this turn
        if current_turn_actions['leveled_spell_cast'] && spell_level > 0
          errors << 'You have already cast a leveled spell this turn.'
          return { errors: errors, warnings: warnings }
        end
      end

      # Check for concentration (only warnings, doesn't prevent casting)
      if requires_concentration && character&.conditions.to_s.include?('concentrating:')
        current_spell = character.conditions.to_s.match(/concentrating:(\w+)/)&.captures&.first
        warnings << "Casting #{spell_name} will end your concentration on #{current_spell}."
      end

      { errors: errors, warnings: warnings }
    end

    # Validate class feature usage
    def validate_feature_use(params)
      errors = []
      feature_name = params[:feature_name]
      resource_type = params[:resource_type]

      resources = combat_tracker&.action_resources || {}
      class_features = resources['class_features'] || {}

      if class_features[resource_type]
        total = class_features[resource_type]['total'] || 0
        used = class_features[resource_type]['used'] || 0

        if used >= total
          errors << "You have no uses remaining for #{feature_name} (#{used}/#{total} used)."
        end
      end

      { errors: errors }
    end

    # Validate reaction usage
    def validate_reaction(params)
      errors = []

      if !can_take_action?('reaction')
        errors << 'You have already used your reaction this round.'
      end

      { errors: errors }
    end

    # Check if action is available in action economy
    def can_take_action?(action_type)
      return true if action_type == 'free' || action_type.nil?

      current_turn_actions = combat_tracker&.action_resources&.dig('current_turn_actions') || {}

      case action_type
      when 'action'
        !current_turn_actions['action_used']
      when 'bonus_action'
        !current_turn_actions['bonus_action_used']
      when 'reaction'
        !current_turn_actions['reaction_used']
      else
        true
      end
    end

    # Check if spell slot is available
    def has_spell_slot?(spell_level)
      return false if spell_level <= 0 # Cantrips don't use slots

      resources = combat_tracker&.action_resources || {}
      spell_slots_total = resources['spell_slots_total'] || {}
      spell_slots_used = resources['spell_slots_used'] || {}

      level_key = spell_level_key(spell_level)
      total = spell_slots_total[level_key] || 0
      used = spell_slots_used[level_key] || 0

      used < total
    end

    # Check if movement is available
    def has_movement_remaining?(distance)
      current_movement = combat_tracker&.action_resources&.dig('current_turn_movement') || 0
      resources = combat_tracker&.action_resources || {}
      dashed = resources.dig('current_turn_actions', 'dashed') || false

      max_movement = character&.speed || 30
      max_movement *= 2 if dashed

      (current_movement + distance) <= max_movement
    end

    # Check if character is incapacitated
    def is_incapacitated?
      conditions = character&.conditions || []
      conditions = [conditions] if conditions.is_a?(String)

      (conditions & INCAPACITATING_CONDITIONS).any?
    end

    # Reset turn actions (called at start of turn)
    def reset_turn_actions!
      tracker = combat_tracker
      return unless tracker

      resources = tracker.action_resources || {}
      resources['current_turn_actions'] = {
        'action_used' => false,
        'bonus_action_used' => false,
        'reaction_used' => false,
        'leveled_spell_cast' => false,
        'bonus_action_spell_cast' => false,
        'dashed' => false
      }
      resources['current_turn_movement'] = 0

      # Mark JSONB as changed for PostgreSQL
      tracker.action_resources_will_change!
      tracker.action_resources = resources
      tracker.save!
    end

    # Record that an action was taken
    def record_action!(action_type, action_params = {})
      tracker = combat_tracker
      return unless tracker

      resources = tracker.action_resources || {}
      current_turn_actions = resources['current_turn_actions'] || {}

      case action_type
      when 'action'
        current_turn_actions['action_used'] = true
      when 'bonus_action'
        current_turn_actions['bonus_action_used'] = true
      when 'reaction'
        current_turn_actions['reaction_used'] = true
      end

      # Track spell casting (D&D 5e spell casting restrictions)
      if action_params[:spell_level] && action_params[:spell_level] > 0
        current_turn_actions['leveled_spell_cast'] = true
      end

      if action_params[:casting_time] == 'bonus_action'
        current_turn_actions['bonus_action_spell_cast'] = true
      end

      # Track dash
      if action_params[:action_type] == 'dash'
        current_turn_actions['dashed'] = true
      end

      # Update movement
      if action_params[:distance]
        current_movement = resources['current_turn_movement'] || 0
        resources['current_turn_movement'] = current_movement + action_params[:distance]
      end

      resources['current_turn_actions'] = current_turn_actions

      # Mark JSONB as changed for PostgreSQL
      tracker.action_resources_will_change!
      tracker.action_resources = resources
      tracker.save!
    end

    # Get helpful validation message
    def get_validation_message(error_type, context = {})
      case error_type
      when :no_spell_slots
        level = context[:spell_level]
        "You have no #{spell_level_name(level)}-level spell slots remaining. You can regain spell slots by taking a long rest."
      when :movement_exceeded
        attempted = context[:attempted]
        remaining = context[:remaining]
        "Moving #{attempted} feet exceeds your movement speed. You have #{remaining} feet remaining this turn."
      when :action_used
        'You have already used your action this turn. You can only take one action per turn unless you have a feature that grants additional actions.'
      when :bonus_action_used
        'You have already used your bonus action this turn. You can only take one bonus action per turn.'
      when :reaction_used
        'You have already used your reaction this round. You regain your reaction at the start of your next turn.'
      when :incapacitated
        'You cannot take actions while incapacitated. Some conditions (paralyzed, stunned, unconscious, petrified) prevent you from acting.'
      else
        'This action cannot be performed.'
      end
    end

    private

    # Get the character for this session
    def character
      @character ||= terminal_session.character
    end

    # Get the combat tracker for this character
    def combat_tracker
      return nil unless character

      @combat_tracker ||= character.character_combat_tracker ||
                          character.create_character_combat_tracker!(
                            action_resources: {},
                            exhaustion_level: 0,
                            temp_hp: 0
                          )
    end

    # Determine action cost based on action type
    def determine_action_cost(action_type, params)
      case action_type
      when 'attack'
        'action'
      when 'bonus_attack'
        'bonus_action'
      when 'cast_spell'
        params[:casting_time] || 'action'
      when 'use_feature'
        params[:action_cost] || 'action'
      when 'opportunity_attack'
        'reaction'
      when 'move'
        'free'
      else
        'action'
      end
    end

    # Convert spell level to key format
    def spell_level_key(level)
      case level
      when 1 then '1st'
      when 2 then '2nd'
      when 3 then '3rd'
      else "#{level}th"
      end
    end

    # Convert spell level to readable name
    def spell_level_name(level)
      case level
      when 1 then '1st'
      when 2 then '2nd'
      when 3 then '3rd'
      when 4 then '4th'
      when 5 then '5th'
      when 6 then '6th'
      when 7 then '7th'
      when 8 then '8th'
      when 9 then '9th'
      else level.to_s
      end
    end
  end
end
