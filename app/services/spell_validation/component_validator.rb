# frozen_string_literal: true

module SpellValidation
  # ComponentValidator - Validates spell component requirements (V, S, M)
  # Implements D&D 5e spell component rules
  #
  # Component Types:
  # - V (Verbal): Requires ability to speak
  # - S (Somatic): Requires at least one free hand
  # - M (Material): Requires component pouch or specific materials
  #
  # Special Cases:
  # - War Caster feat: Can perform somatic components with hands full
  # - Subtle Spell (Metamagic): Removes V and S components
  # - Component Pouch: Provides all non-costly materials
  # - Costly Materials: Must be provided explicitly and consumed
  class ComponentValidator
    attr_reader :character, :spell

    def initialize(character, spell)
      @character = character
      @spell = spell
    end

    # Validate all spell components
    # Returns { valid: true/false, errors: [], warnings: [] }
    def validate_components
      errors = []
      warnings = []

      # Skip validation if using Subtle Spell metamagic
      if spell_has_subtle_metamagic?
        return { valid: true, errors: [], warnings: ['Using Subtle Spell - no components required'] }
      end

      # Parse component requirements
      components = parse_components

      # Validate verbal component
      if components[:verbal]
        verbal_result = validate_verbal_component
        errors.concat(verbal_result[:errors])
        warnings.concat(verbal_result[:warnings])
      end

      # Validate somatic component
      if components[:somatic]
        somatic_result = validate_somatic_component
        errors.concat(somatic_result[:errors])
        warnings.concat(somatic_result[:warnings])
      end

      # Validate material component
      if components[:material]
        material_result = validate_material_component(components[:material_details])
        errors.concat(material_result[:errors])
        warnings.concat(material_result[:warnings])
      end

      {
        valid: errors.empty?,
        errors: errors,
        warnings: warnings
      }
    end

    # Check if character can provide verbal components
    def validate_verbal_component
      errors = []
      warnings = []

      # Check for silencing conditions
      if is_silenced?
        errors << "You cannot cast spells with verbal components while silenced."
      end

      # Check for deafened condition (disadvantage on perception, but can still cast)
      if is_deafened?
        warnings << "You are deafened - this may affect spell targeting and perception."
      end

      { errors: errors, warnings: warnings }
    end

    # Check if character can provide somatic components
    def validate_somatic_component
      errors = []
      warnings = []

      # War Caster feat allows somatic components with hands full
      if has_war_caster_feat?
        warnings << "War Caster feat allows somatic components with hands full."
        return { errors: [], warnings: warnings }
      end

      # Check if character has at least one free hand
      unless has_free_hand?
        errors << "You need at least one free hand to perform somatic components. Sheathe a weapon or drop an item."
      end

      # Check for restrained condition
      if is_restrained?
        errors << "You cannot perform somatic components while restrained."
      end

      { errors: errors, warnings: warnings }
    end

    # Check if character can provide material components
    def validate_material_component(material_details)
      errors = []
      warnings = []

      # Parse material cost if present
      cost = extract_material_cost(material_details)

      if cost && cost > 0
        # Costly materials must be provided explicitly
        unless has_costly_material?(material_details, cost)
          errors << "You need #{material_details} (worth #{cost} gp) to cast this spell."
        end

        # Check if material is consumed
        if material_is_consumed?(material_details)
          warnings << "This spell consumes the material component (#{material_details})."
        end
      else
        # Non-costly materials can be provided by component pouch
        unless has_component_pouch? || has_specific_material?(material_details)
          errors << "You need a component pouch or #{material_details} to cast this spell."
        end
      end

      { errors: errors, warnings: warnings }
    end

    private

    # Parse spell component string (e.g., "V, S, M (a pinch of sulfur)")
    def parse_components
      return {} unless spell.respond_to?(:components)

      components_str = spell.components.to_s
      {
        verbal: components_str.include?('V'),
        somatic: components_str.include?('S'),
        material: components_str.include?('M'),
        material_details: extract_material_details(components_str)
      }
    end

    # Extract material component details from parentheses
    def extract_material_details(components_str)
      match = components_str.match(/M\s*\(([^)]+)\)/)
      match ? match[1].strip : nil
    end

    # Extract gold cost from material details
    # Examples: "diamond worth 1,000 gp", "a ruby worth at least 50 gp"
    def extract_material_cost(material_details)
      return 0 unless material_details

      # Match patterns like "1,000 gp", "50 gp", "at least 500 gp"
      match = material_details.match(/(\d+(?:,\d+)*)\s*gp/)
      return 0 unless match

      match[1].gsub(',', '').to_i
    end

    # Check if material is consumed by the spell
    def material_is_consumed?(material_details)
      return false unless material_details

      # Common indicators that material is consumed
      consumed_keywords = ['consumed', 'which the spell consumes', 'that is consumed']
      consumed_keywords.any? { |keyword| material_details.downcase.include?(keyword) }
    end

    # Check if character is silenced
    def is_silenced?
      conditions = character_conditions
      conditions.include?('silenced') || conditions.include?('silence')
    end

    # Check if character is deafened
    def is_deafened?
      conditions = character_conditions
      conditions.include?('deafened')
    end

    # Check if character is restrained
    def is_restrained?
      conditions = character_conditions
      conditions.include?('restrained')
    end

    # Check if character has War Caster feat
    def has_war_caster_feat?
      return false unless character.respond_to?(:feats)

      character.feats.any? { |feat| feat.name.to_s.downcase.include?('war caster') }
    end

    # Check if character has at least one free hand
    def has_free_hand?
      # This is a simplified check - in a full implementation, you'd track
      # what's in each hand (weapon, shield, focus, etc.)
      # For now, we'll assume:
      # - Two-handed weapons = no free hands
      # - Weapon + shield = no free hands
      # - One weapon = one free hand
      # - No weapons = free hands

      # If character has War Caster, this is always true
      return true if has_war_caster_feat?

      # For now, return true as default (can be enhanced later)
      # TODO: Implement proper hand tracking when equipment system is complete
      true
    end

    # Check if character has component pouch
    def has_component_pouch?
      return false unless character.respond_to?(:character_inventory)

      inventory = character.character_inventory
      return false unless inventory

      # Check if inventory has component pouch item
      inventory_items = inventory.inventory_items || []
      inventory_items.any? { |item_data| item_data[:item]&.name&.downcase&.include?('component pouch') }
    end

    # Check if character has specific material
    def has_specific_material?(material_details)
      return false unless material_details
      return false unless character.respond_to?(:character_inventory)

      inventory = character.character_inventory
      return false unless inventory

      # Search inventory for material by name
      inventory_items = inventory.inventory_items || []
      inventory_items.any? do |item_data|
        item = item_data[:item]
        next false unless item

        # Match material name in item name or description
        item.name&.downcase&.include?(material_details.downcase) ||
          item.description&.downcase&.include?(material_details.downcase)
      end
    end

    # Check if character has costly material
    def has_costly_material?(material_details, cost)
      return false unless character.respond_to?(:character_inventory)

      inventory = character.character_inventory
      return false unless inventory

      # Check if character has enough gold via inventory currency system
      total_gold = inventory.total_wealth_in_gp
      total_gold >= cost
    end

    # Check if spell uses Subtle Spell metamagic
    def spell_has_subtle_metamagic?
      # This would be set when casting with metamagic
      # For now, return false - enhance when integrating with spell casting
      false
    end

    # Get character conditions as array
    def character_conditions
      return [] unless character.respond_to?(:conditions)

      conditions = character.conditions
      return [] if conditions.nil?

      # Handle different condition formats
      case conditions
      when Array
        conditions.map(&:to_s).map(&:downcase)
      when String
        conditions.split(',').map(&:strip).map(&:downcase)
      else
        []
      end
    end
  end
end
