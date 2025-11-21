# frozen_string_literal: true

module AiDm
  # RulesExplainerService - Provides natural language explanations of D&D 5e rules
  # Used by AI DM to give helpful feedback when players attempt invalid actions
  class RulesExplainerService
    attr_reader :character

    def initialize(character)
      @character = character
    end

    # Explain why a spell cannot be cast
    def explain_spell_failure(spell, validation_result)
      explanation_parts = []

      # Header
      explanation_parts << "**Cannot cast #{spell.name}:**\n"

      # Errors
      if validation_result[:errors].any?
        explanation_parts << validation_result[:errors].map { |error| "❌ #{error}" }.join("\n")
      end

      # Warnings (if any)
      if validation_result[:warnings].any?
        explanation_parts << "\n**Warnings:**"
        explanation_parts << validation_result[:warnings].map { |warning| "⚠️  #{warning}" }.join("\n")
      end

      # Suggestions
      if validation_result[:suggestions].any?
        explanation_parts << "\n**Suggestions:**"
        explanation_parts << validation_result[:suggestions].map { |suggestion| "💡 #{suggestion}" }.join("\n")
      end

      # Add spell component requirements for context
      if spell.components
        explanation_parts << "\n**Spell Requirements:**"
        explanation_parts << "- Components: #{spell.components}"

        if spell.material
          explanation_parts << "- Materials: #{spell.material}"
        end

        if spell.concentration?
          explanation_parts << "- Requires Concentration"
        end
      end

      explanation_parts.join("\n")
    end

    # Explain action economy and why an action cannot be taken
    def explain_action_economy_failure(action_type, validation_result)
      explanation_parts = []

      tracker = character.character_combat_tracker

      explanation_parts << "**Cannot perform #{action_type.humanize}:**\n"

      # Errors
      if validation_result[:errors].any?
        explanation_parts << validation_result[:errors].map { |error| "❌ #{error}" }.join("\n")
      end

      # Current action economy status
      if tracker
        explanation_parts << "\n**Current Turn Status:**"
        explanation_parts << "- Action: #{tracker.action_available? ? '✅ Available' : '❌ Used'}"
        explanation_parts << "- Bonus Action: #{tracker.has_bonus_action? ? '✅ Available' : '❌ Used'}"
        explanation_parts << "- Reaction: #{tracker.has_reaction? ? '✅ Available' : '❌ Used (resets next turn)'}"
        explanation_parts << "- Movement: #{tracker.remaining_movement} ft remaining"
      end

      # Suggestions
      if validation_result[:suggestions].any?
        explanation_parts << "\n**Alternatives:**"
        explanation_parts << validation_result[:suggestions].map { |suggestion| "💡 #{suggestion}" }.join("\n")
      end

      # Action economy rules reference
      explanation_parts << "\n**D&D 5e Action Economy:**"
      explanation_parts << "On your turn, you can:"
      explanation_parts << "- Take ONE action (Attack, Cast Spell, Dash, Disengage, Dodge, Help, Hide, Ready, Search, Use Object)"
      explanation_parts << "- Take ONE bonus action (if you have a feature that grants it)"
      explanation_parts << "- Move up to your speed"
      explanation_parts << "- Use ONE reaction per round (triggers on other turns)"

      explanation_parts.join("\n")
    end

    # Explain condition effects
    def explain_condition(condition_name)
      case condition_name.downcase
      when 'blinded'
        <<~EXPLAIN
          **Blinded (PHB p. 290)**
          - You can't see and automatically fail any ability check that requires sight
          - Attack rolls against you have advantage
          - Your attack rolls have disadvantage
        EXPLAIN

      when 'charmed'
        <<~EXPLAIN
          **Charmed (PHB p. 290)**
          - You can't attack the charmer or target them with harmful abilities or magical effects
          - The charmer has advantage on ability checks to interact socially with you
        EXPLAIN

      when 'deafened'
        <<~EXPLAIN
          **Deafened (PHB p. 290)**
          - You can't hear and automatically fail any ability check that requires hearing
        EXPLAIN

      when 'frightened'
        <<~EXPLAIN
          **Frightened (PHB p. 290)**
          - You have disadvantage on ability checks and attack rolls while the source of fear is within line of sight
          - You can't willingly move closer to the source of your fear
        EXPLAIN

      when 'grappled'
        <<~EXPLAIN
          **Grappled (PHB p. 290)**
          - Your speed becomes 0, and you can't benefit from bonuses to your speed
          - The condition ends if the grappler is incapacitated
          - You can use your action to escape with an Athletics or Acrobatics check
        EXPLAIN

      when 'incapacitated'
        <<~EXPLAIN
          **Incapacitated (PHB p. 290)**
          - You can't take actions or reactions
        EXPLAIN

      when 'invisible'
        <<~EXPLAIN
          **Invisible (PHB p. 291)**
          - You can't be seen without the aid of magic or special sense
          - You are considered heavily obscured for purposes of hiding
          - Attack rolls against you have disadvantage
          - Your attack rolls have advantage
        EXPLAIN

      when 'paralyzed'
        <<~EXPLAIN
          **Paralyzed (PHB p. 291)**
          - You are incapacitated and can't move or speak
          - You automatically fail Strength and Dexterity saving throws
          - Attack rolls against you have advantage
          - Any attack that hits you is a critical hit if the attacker is within 5 feet
        EXPLAIN

      when 'petrified'
        <<~EXPLAIN
          **Petrified (PHB p. 291)**
          - You are transformed into a solid inanimate substance (stone)
          - Your weight increases by a factor of ten, and you cease aging
          - You are incapacitated, can't move or speak, and are unaware of your surroundings
          - Attack rolls against you have advantage
          - You automatically fail Strength and Dexterity saving throws
          - You have resistance to all damage
          - You are immune to poison and disease (existing poison/disease is suspended)
        EXPLAIN

      when 'poisoned'
        <<~EXPLAIN
          **Poisoned (PHB p. 292)**
          - You have disadvantage on attack rolls and ability checks
        EXPLAIN

      when 'prone'
        <<~EXPLAIN
          **Prone (PHB p. 292)**
          - Your only movement option is to crawl (costs 1 extra foot per foot moved)
          - You can stand up (costs half your movement speed)
          - You have disadvantage on attack rolls
          - Melee attacks against you have advantage
          - Ranged attacks against you have disadvantage
        EXPLAIN

      when 'restrained'
        <<~EXPLAIN
          **Restrained (PHB p. 292)**
          - Your speed becomes 0, and you can't benefit from bonuses to your speed
          - Attack rolls against you have advantage
          - Your attack rolls have disadvantage
          - You have disadvantage on Dexterity saving throws
        EXPLAIN

      when 'stunned'
        <<~EXPLAIN
          **Stunned (PHB p. 292)**
          - You are incapacitated, can't move, and can speak only falteringly
          - You automatically fail Strength and Dexterity saving throws
          - Attack rolls against you have advantage
        EXPLAIN

      when 'unconscious'
        <<~EXPLAIN
          **Unconscious (PHB p. 292)**
          - You are incapacitated, can't move or speak, and are unaware of your surroundings
          - You drop whatever you're holding and fall prone
          - You automatically fail Strength and Dexterity saving throws
          - Attack rolls against you have advantage
          - Any attack that hits you is a critical hit if the attacker is within 5 feet
        EXPLAIN

      when 'exhaustion'
        <<~EXPLAIN
          **Exhaustion (PHB p. 291)**
          Levels of exhaustion:
          1. Disadvantage on ability checks
          2. Speed halved
          3. Disadvantage on attack rolls and saving throws
          4. Hit point maximum halved
          5. Speed reduced to 0
          6. Death

          Effects are cumulative. One long rest reduces exhaustion by 1 level.
        EXPLAIN

      else
        "**#{condition_name.titleize}**\nCondition not found in standard D&D 5e rules. This may be a custom condition."
      end
    end

    # Explain spell slot mechanics
    def explain_spell_slots
      spell_manager = character.character_spell_manager
      return "**Character does not have spellcasting ability.**" unless spell_manager

      explanation = []
      explanation << "**Spell Slots (PHB p. 201)**\n"

      explanation << "You use spell slots to cast spells of 1st level and higher."
      explanation << "When you cast a spell, you expend a slot of that spell's level or higher.\n"

      explanation << "**Your Current Slots:**"
      spell_slots = spell_manager.spell_slots || {}
      (1..9).each do |level|
        count = spell_slots[level.to_s] || 0
        next if count <= 0

        explanation << "- Level #{level}: #{count} slot#{'s' if count > 1}"
      end

      explanation << "\n**Recovering Slots:**"
      explanation << "- You regain all expended spell slots when you finish a long rest"
      explanation << "- Some classes (Wizard Arcane Recovery, Warlock Pact Magic) can recover slots during a short rest"

      explanation << "\n**Upcasting:**"
      explanation << "You can cast a spell using a higher-level slot than required."
      explanation << "Many spells deal more damage or have enhanced effects when upcast."
      explanation << "Example: *Magic Missile* cast using a 2nd-level slot creates 4 darts instead of 3."

      explanation.join("\n")
    end

    # Explain concentration mechanics
    def explain_concentration
      <<~EXPLAIN
        **Concentration (PHB p. 203-204)**

        Some spells require you to maintain concentration to keep their magic active.

        **Concentration Rules:**
        - You can concentrate on only ONE spell at a time
        - Casting another concentration spell ends the first one
        - You must maintain concentration for the spell's duration

        **Breaking Concentration:**
        You lose concentration if:
        - You cast another concentration spell
        - You take damage (make a Constitution saving throw, DC = 10 or half damage, whichever is higher)
        - You are incapacitated or killed
        - Environmental phenomena (DM's discretion)

        **Current Concentration:**
      EXPLAIN
    end

    # Explain encumbrance and carrying capacity
    def explain_encumbrance
      inventory = character.character_inventory
      return "**Character does not have inventory system.**" unless inventory

      explanation = []
      explanation << "**Carrying Capacity (PHB p. 176)**\n"

      capacity = inventory.carry_capacity
      current_weight = inventory.current_weight
      strength = character.strength

      explanation << "Your carrying capacity is **#{capacity} lbs** (Strength × 15)"
      explanation << "Current weight: **#{current_weight} lbs**\n"

      explanation << "**Encumbrance Levels:**"
      explanation << "- Normal: 0-#{strength * 5} lbs (no penalties)"
      explanation << "- Encumbered: #{strength * 5 + 1}-#{strength * 10} lbs (speed -10 feet)"
      explanation << "- Heavily Encumbered: #{strength * 10 + 1}-#{strength * 15} lbs (speed -20 feet, disadvantage on ability checks, attacks, saves using STR/DEX/CON)"
      explanation << "- Over Capacity: #{strength * 15 + 1}+ lbs (cannot move)\n"

      encumbrance_status = inventory.encumbrance_status
      explanation << "**Current Status:** #{encumbrance_status.to_s.titleize}"

      if encumbrance_status != 'normal'
        explanation << "\n**Effects:**"
        case encumbrance_status
        when 'encumbered'
          explanation << "- Your speed is reduced by 10 feet"
        when 'heavily_encumbered'
          explanation << "- Your speed is reduced by 20 feet"
          explanation << "- You have disadvantage on ability checks, attack rolls, and saving throws that use Strength, Dexterity, or Constitution"
        when 'over_capacity'
          explanation << "- You cannot move until you drop enough weight to be within carrying capacity"
        end
      end

      explanation.join("\n")
    end

    # Explain attunement rules
    def explain_attunement
      inventory = character.character_inventory

      explanation = []
      explanation << "**Attunement (DMG p. 136)**\n"

      explanation << "Some magic items require attunement before you can use their properties."

      explanation << "\n**Attunement Rules:**"
      explanation << "- You can attune to a maximum of **3 items** at once"
      explanation << "- Attuning requires a **short rest** (1 hour) focusing on the item"
      explanation << "- Attunement ends if:"
      explanation << "  - You die"
      explanation << "  - You unattune (no action required)"
      explanation << "  - Another creature attunes to the item"
      explanation << "  - You are more than 100 feet from the item for 24 hours"

      if inventory
        attuned_count = inventory.attuned_items.length
        explanation << "\n**Your Attunement:**"
        explanation << "- Attuned Items: #{attuned_count}/3"

        if attuned_count >= 3
          explanation << "- You are at maximum attunement. Unattune from an item to attune to a new one."
        end
      end

      explanation.join("\n")
    end

    # Get a helpful message when validation fails
    def validation_failure_message(validation_result)
      parts = []

      if validation_result[:errors].any?
        parts << validation_result[:errors].map { |error| "❌ #{error}" }.join("\n")
      end

      if validation_result[:warnings].any?
        parts << validation_result[:warnings].map { |warning| "⚠️  #{warning}" }.join("\n")
      end

      if validation_result[:suggestions].any?
        parts << "\n**Try Instead:**"
        parts << validation_result[:suggestions].map { |suggestion| "💡 #{suggestion}" }.join("\n")
      end

      parts.join("\n")
    end
  end
end
