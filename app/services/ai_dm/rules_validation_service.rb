# frozen_string_literal: true

module AiDm
  # RulesValidationService - Validates player and AI DM actions against D&D 5e rules
  # Integrates with Phase 2 validators (ActionValidator, ComponentValidator, RangeValidator)
  # Provides validation before AI DM suggests or executes actions
  class RulesValidationService
    attr_reader :character, :session

    def initialize(character, terminal_session)
      @character = character
      @session = terminal_session
    end

    # Validate if character can cast a spell
    # Returns { valid: true/false, errors: [], warnings: [], suggestions: [] }
    def validate_spell_cast(spell, options = {})
      errors = []
      warnings = []
      suggestions = []

      # Check if spell exists
      unless spell
        return validation_result(false, ['Spell not found'], [], [])
      end

      # Get spell manager
      spell_manager = character.character_spell_manager
      unless spell_manager
        return validation_result(false, ['Character does not have spell manager'], [],
                                ['Character may not be a spellcaster'])
      end

      # Validate spell components
      component_validator = SpellValidation::ComponentValidator.new(character, spell)
      component_result = component_validator.validate_components

      errors.concat(component_result[:errors])
      warnings.concat(component_result[:warnings])

      # Validate range and targeting
      if options[:target_id]
        range_validator = SpellValidation::RangeValidator.new(spell, character, options)
        range_result = range_validator.validate_range

        errors.concat(range_result[:errors])
        warnings.concat(range_result[:warnings])
      end

      # Check spell slots
      spell_level = spell.level.to_i
      if spell_level > 0 # Not a cantrip
        available_slots = spell_manager.spell_slots[spell_level.to_s] || 0
        if available_slots <= 0
          errors << "No #{spell_level.ordinalize}-level spell slots available"

          # Suggest upcasting if higher slots available
          (spell_level + 1..9).each do |higher_level|
            if (spell_manager.spell_slots[higher_level.to_s] || 0) > 0
              suggestions << "You could cast #{spell.name} using a #{higher_level.ordinalize}-level slot"
              break
            end
          end
        end
      end

      # Check if spell is prepared (for prepared casters)
      if spell_manager.requires_preparation?
        prepared_spells = spell_manager.prepared_spells || []
        unless prepared_spells.include?(spell.id)
          errors << "#{spell.name} is not prepared"
          suggestions << "You must prepare #{spell.name} during a long rest to cast it"
        end
      end

      # Check concentration
      if spell.concentration?
        concentration = spell_manager.concentration
        if concentration && concentration['spell_id']
          active_spell = Spell.find_by(id: concentration['spell_id'])
          if active_spell
            warnings << "Casting #{spell.name} will end concentration on #{active_spell.name}"
            suggestions << "Consider whether you want to maintain #{active_spell.name}"
          end
        end
      end

      validation_result(errors.empty?, errors, warnings, suggestions)
    end

    # Validate if character can perform an action (attack, dash, dodge, etc.)
    # Returns { valid: true/false, errors: [], warnings: [], suggestions: [] }
    def validate_action(action_type, action_params = {})
      errors = []
      warnings = []
      suggestions = []

      tracker = character.character_combat_tracker
      unless tracker
        return validation_result(true, [], [], []) # No combat, action is valid
      end

      # Validate action economy
      case action_type
      when 'attack', 'cast_spell', 'dash', 'disengage', 'dodge', 'help', 'hide', 'ready', 'search', 'use_object'
        unless tracker.action_available?
          errors << "Action already used this turn"
          suggestions << "You still have your bonus action and movement available" if tracker.has_bonus_action?
        end

      when 'bonus_action'
        unless tracker.has_bonus_action?
          errors << "Bonus action already used this turn"
          suggestions << "You still have your action and movement available" if tracker.action_available?
        end

      when 'reaction'
        unless tracker.has_reaction?
          errors << "Reaction already used this round"
          suggestions << "Your reaction will be available at the start of your next turn"
        end

      when 'movement'
        feet = action_params[:feet] || 0
        remaining = tracker.remaining_movement
        if feet > remaining
          errors << "Insufficient movement: #{feet} feet requested, #{remaining} feet remaining"
          suggestions << "You could Dash to gain additional movement equal to your speed"
        end
      end

      # Check conditions that prevent actions
      active_conditions = tracker.active_conditions || []
      active_conditions.each do |condition|
        case condition['name']&.downcase
        when 'stunned'
          errors << "You cannot take actions or reactions while stunned"
        when 'paralyzed'
          errors << "You cannot take actions or reactions while paralyzed"
        when 'unconscious'
          errors << "You cannot take actions or reactions while unconscious"
        when 'petrified'
          errors << "You cannot take actions or reactions while petrified"
        when 'incapacitated'
          errors << "You cannot take actions or reactions while incapacitated"
        when 'restrained'
          if action_type == 'movement'
            warnings << "Your speed is 0 while restrained - you cannot move"
          end
        end
      end

      validation_result(errors.empty?, errors, warnings, suggestions)
    end

    # Validate inventory action (equip item, use item, etc.)
    # Returns { valid: true/false, errors: [], warnings: [], suggestions: [] }
    def validate_inventory_action(action_type, item_id, options = {})
      errors = []
      warnings = []
      suggestions = []

      inventory = character.character_inventory
      unless inventory
        errors << "Character does not have inventory system"
        return validation_result(false, errors, warnings, suggestions)
      end

      # Find item in inventory
      inventory_items = inventory.inventory_items || []
      item_data = inventory_items.find { |i| i[:item]&.id == item_id }

      unless item_data
        errors << "Item not found in inventory"
        return validation_result(false, errors, warnings, suggestions)
      end

      item = item_data[:item]

      case action_type
      when 'equip'
        # Check if slot is available
        slot = options[:slot] || item.equipment_slot
        if slot
          equipped_items = inventory.equipped_items || {}
          current_item = equipped_items[slot]

          if current_item
            warnings << "Slot #{slot} is occupied by #{current_item[:name]}"
            suggestions << "Unequip #{current_item[:name]} first, or it will be automatically unequipped"
          end
        end

        # Check attunement
        if item.requires_attunement && !item_data[:attuned]
          warnings << "#{item.name} requires attunement"
          suggestions << "You must attune to #{item.name} during a short rest (requires 1 hour)"

          # Check attunement slots
          attuned_count = inventory.attuned_items.length
          if attuned_count >= 3
            errors << "Maximum attunement slots (3) already in use"
            suggestions << "You must unattune from another item first"
          end
        end

      when 'attune'
        unless item.requires_attunement
          errors << "#{item.name} does not require attunement"
          return validation_result(false, errors, warnings, suggestions)
        end

        if item_data[:attuned]
          errors << "#{item.name} is already attuned"
          return validation_result(false, errors, warnings, suggestions)
        end

        # Check attunement slots
        attuned_count = inventory.attuned_items.length
        if attuned_count >= 3
          errors << "Maximum attunement slots (3) already in use"
          attuned_items = inventory.attuned_items
          suggestions << "You must unattune from one of: #{attuned_items.map { |id| inventory_items.find { |i| i[:item]&.id == id }[:item]&.name }.compact.join(', ')}"
        end

      when 'use'
        # Check if item is consumable
        if item.item_type == 'potion'
          tracker = character.character_combat_tracker
          if tracker && !tracker.can_use_action? && !tracker.can_use_bonus_action?
            errors << "Using a potion requires an action (or bonus action with Fast Hands)"
          end
        end

        # Check quantity
        quantity = item_data[:quantity] || 1
        if quantity <= 0
          errors << "No #{item.name} remaining"
        end
      end

      validation_result(errors.empty?, errors, warnings, suggestions)
    end

    # Validate movement action (including difficult terrain, grappled, etc.)
    # Returns { valid: true/false, errors: [], warnings: [], suggestions: [], movement_cost: int }
    def validate_movement(feet, options = {})
      errors = []
      warnings = []
      suggestions = []

      tracker = character.character_combat_tracker
      unless tracker
        # Outside combat, movement is generally valid
        return validation_result(true, [], [], []).merge(movement_cost: feet)
      end

      remaining = tracker.remaining_movement
      movement_cost = feet

      # Check conditions
      active_conditions = tracker.active_conditions || []
      active_conditions.each do |condition|
        case condition['name']&.downcase
        when 'grappled'
          warnings << "Your speed is 0 while grappled"
          errors << "You cannot move while grappled"
          suggestions << "You must use an action to escape the grapple (Athletics or Acrobatics check)"

        when 'restrained'
          warnings << "Your speed is 0 while restrained"
          errors << "You cannot move while restrained"

        when 'prone'
          warnings << "Standing up from prone costs half your movement (#{character.speed / 2} feet)"
          if options[:standing_up]
            movement_cost += (character.speed / 2)
          else
            suggestions << "You are prone - consider standing up (costs half movement) or crawling"
          end
        end
      end

      # Check difficult terrain
      if options[:difficult_terrain]
        movement_cost *= 2
        warnings << "Moving through difficult terrain costs 2 feet for every 1 foot of movement"
      end

      # Check if enough movement remaining
      if movement_cost > remaining
        errors << "Insufficient movement: #{movement_cost} feet needed, #{remaining} feet remaining"

        # Suggest Dash
        if tracker.can_use_action?
          suggestions << "You could use your action to Dash, gaining #{character.speed} additional feet of movement"
        end
      end

      validation_result(errors.empty?, errors, warnings, suggestions).merge(movement_cost: movement_cost)
    end

    private

    def validation_result(valid, errors, warnings, suggestions)
      {
        valid: valid,
        errors: errors,
        warnings: warnings,
        suggestions: suggestions
      }
    end
  end
end
