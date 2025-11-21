# frozen_string_literal: true

module AiDm
  # Generates context-aware suggestions for what the user can do next
  # Analyzes character state, game state, and recent actions to provide helpful guidance
  class SuggestionEngine
    attr_reader :character, :session, :campaign

    def initialize(character, session = nil)
      @character = character
      @session = session
      @campaign = character&.campaign
    end

    # Generate suggestions after a specific tool execution
    def suggestions_after_tool(tool_name, tool_result = {})
      case tool_name
      when 'create_character'
        suggestions_after_character_creation
      when 'roll_ability_scores'
        suggestions_after_ability_scores
      when 'assign_ability_score'
        suggestions_after_ability_assignment
      when 'level_up'
        suggestions_after_level_up
      when 'cast_spell'
        suggestions_after_spell_cast(tool_result)
      when 'attack'
        suggestions_in_combat
      when 'add_item_to_inventory'
        suggestions_after_inventory_change
      when 'rest'
        suggestions_after_rest(tool_result)
      else
        general_suggestions
      end
    end

    # Suggestions after creating a new character
    def suggestions_after_character_creation
      return [] unless character

      suggestions = []

      # Check character completeness
      if missing_ability_scores?
        suggestions << {
          icon: '🎲',
          action: 'Roll ability scores',
          examples: ['roll my stats', 'roll ability scores', 'generate stats']
        }
      end

      if missing_class?
        suggestions << {
          icon: '⚔️',
          action: 'Choose your class',
          examples: ['I want to be a wizard', 'make me a fighter', 'what classes are available?']
        }
      end

      if missing_race?
        suggestions << {
          icon: '🧝',
          action: 'Choose your race',
          examples: ['I want to be an elf', 'make me a dwarf', 'what races can I choose?']
        }
      end

      if missing_background?
        suggestions << {
          icon: '📜',
          action: 'Choose a background',
          examples: ['I want to be a sage', 'give me the soldier background', 'what backgrounds exist?']
        }
      end

      if character_complete? && !has_starting_equipment?
        suggestions << {
          icon: '🎒',
          action: 'Get starting equipment',
          examples: ['what equipment do I get?', 'give me starting gear', 'equip me']
        }
      end

      if character_complete? && has_starting_equipment?
        suggestions << {
          icon: '🗺️',
          action: 'Start your adventure',
          examples: ['I enter the tavern', 'begin the adventure', 'what do I see?']
        }
      end

      suggestions.take(4) # Limit to 4 most relevant suggestions
    end

    # Suggestions after rolling ability scores
    def suggestions_after_ability_scores
      suggestions = []

      if ability_scores_unassigned?
        suggestions << {
          icon: '🎯',
          action: 'Assign ability scores',
          examples: ['assign 16 to intelligence', 'put my highest in strength', 'use standard array']
        }
      end

      if ability_scores_assigned? && missing_class?
        suggestions << {
          icon: '⚔️',
          action: 'Choose your class',
          examples: ['I want to be a wizard', 'make me a fighter']
        }
      end

      if ability_scores_assigned? && !missing_class?
        suggestions << {
          icon: '📊',
          action: 'Review your character',
          examples: ['show my character sheet', 'what are my stats?', 'character summary']
        }
      end

      suggestions.take(3)
    end

    # Suggestions after assigning an ability score
    def suggestions_after_ability_assignment
      suggestions = []

      if ability_scores_partially_assigned?
        remaining = unassigned_abilities.join(', ')
        suggestions << {
          icon: '🎯',
          action: "Assign remaining scores (#{remaining})",
          examples: ["assign #{unassigned_abilities.first}", 'continue assigning stats']
        }
      elsif ability_scores_assigned? && missing_class?
        suggestions << {
          icon: '⚔️',
          action: 'Choose your class',
          examples: ['I want to be a wizard', 'make me a rogue']
        }
      end

      suggestions.take(3)
    end

    # Suggestions after leveling up
    def suggestions_after_level_up
      suggestions = []
      level = character.level

      if spellcaster? && new_spells_available?(level)
        suggestions << {
          icon: '✨',
          action: 'Learn new spells',
          examples: ['what spells can I learn?', 'show available spells', 'learn fireball']
        }
      end

      if ability_score_improvement_available?(level)
        suggestions << {
          icon: '📈',
          action: 'Increase ability scores or choose feat',
          examples: ['increase my intelligence', 'I want the War Caster feat', 'what feats are available?']
        }
      end

      suggestions << {
        icon: '📊',
        action: 'Review your new capabilities',
        examples: ['show my character sheet', 'what changed?', 'character summary']
      }

      suggestions << {
        icon: '🗺️',
        action: 'Continue adventuring',
        examples: ['continue the adventure', 'what happens next?', "let's keep going"]
      }

      suggestions.take(3)
    end

    # Suggestions after casting a spell
    def suggestions_after_spell_cast(result)
      suggestions = []

      if in_combat?
        if has_bonus_action?
          suggestions << {
            icon: '⚡',
            action: 'Use bonus action',
            examples: ['cast healing word', 'disengage as bonus action', 'use second wind']
          }
        end

        if has_movement_remaining?
          suggestions << {
            icon: '👟',
            action: 'Move to better position',
            examples: ['move 20 feet north', 'get behind cover', 'approach the enemy']
          }
        end

        suggestions << {
          icon: '✅',
          action: 'End your turn',
          examples: ['end turn', 'finish my turn', "that's all"]
        }
      else
        suggestions << {
          icon: '🗺️',
          action: 'Continue exploration',
          examples: ['what do I see?', 'explore the area', 'continue forward']
        }
      end

      suggestions.take(3)
    end

    # Suggestions while in combat
    def suggestions_in_combat
      suggestions = []

      if has_action?
        suggestions << {
          icon: '⚔️',
          action: 'Attack or cast spell',
          examples: ['attack with longsword', 'cast fireball', 'shoot my bow']
        }
      end

      if has_bonus_action?
        suggestions << {
          icon: '⚡',
          action: 'Use bonus action',
          examples: ['cast healing word', 'off-hand attack', 'use cunning action']
        }
      end

      if has_movement_remaining?
        suggestions << {
          icon: '👟',
          action: 'Move',
          examples: ['move 30 feet', 'approach enemy', 'get to cover']
        }
      end

      if all_actions_used?
        suggestions << {
          icon: '✅',
          action: 'End your turn',
          examples: ['end turn', 'finish turn', "I'm done"]
        }
      end

      suggestions.take(3)
    end

    # Suggestions after adding items to inventory
    def suggestions_after_inventory_change
      suggestions = []

      if unequipped_weapons?
        suggestions << {
          icon: '⚔️',
          action: 'Equip weapons or armor',
          examples: ['equip longsword', 'wear chainmail', 'ready my shield']
        }
      end

      if unattuned_magic_items?
        suggestions << {
          icon: '✨',
          action: 'Attune to magic items',
          examples: ['attune to ring', 'identify the magic sword', 'what does this do?']
        }
      end

      suggestions << {
        icon: '🎒',
        action: 'View inventory',
        examples: ['show inventory', 'what am I carrying?', 'check my gear']
      }

      suggestions << {
        icon: '🗺️',
        action: 'Continue adventuring',
        examples: ['continue forward', 'what happens next?', "let's go"]
      }

      suggestions.take(3)
    end

    # Suggestions after resting
    def suggestions_after_rest(result)
      rest_type = result[:rest_type] || 'short'
      suggestions = []

      if rest_type == 'long'
        if spellcaster?
          suggestions << {
            icon: '📚',
            action: 'Prepare spells',
            examples: ['prepare my spells', 'what spells should I prepare?', 'change prepared spells']
          }
        end

        suggestions << {
          icon: '🗺️',
          action: 'Resume your adventure',
          examples: ['continue the quest', 'what happens next?', "let's go"]
        }
      else
        suggestions << {
          icon: '💪',
          action: 'Continue with restored resources',
          examples: ['continue fighting', 'explore the dungeon', 'keep going']
        }
      end

      suggestions.take(3)
    end

    # General suggestions when no specific context
    def general_suggestions
      return [] unless character

      suggestions = []

      if in_combat?
        return suggestions_in_combat
      end

      # Suggest character sheet review
      suggestions << {
        icon: '📊',
        action: 'View character sheet',
        examples: ['show character', 'character sheet', 'my stats']
      }

      # Suggest inventory check
      suggestions << {
        icon: '🎒',
        action: 'Check inventory',
        examples: ['inventory', 'what am I carrying?', 'show gear']
      }

      # Suggest continuing adventure
      suggestions << {
        icon: '🗺️',
        action: 'Continue adventuring',
        examples: ['what do I see?', 'explore', 'continue forward']
      }

      suggestions.take(3)
    end

    # Format suggestions for display
    def format_suggestions(suggestions)
      return nil if suggestions.empty?

      formatted = ["\n💡 What's next?"]
      suggestions.each do |suggestion|
        formatted << "  #{suggestion[:icon]} #{suggestion[:action]}"
        if suggestion[:examples]
          examples = suggestion[:examples].take(2).map { |ex| "\"#{ex}\"" }.join(' or ')
          formatted << "     Try: #{examples}"
        end
      end
      formatted.join("\n")
    end

    private

    # Character state checks
    def missing_ability_scores?
      return true unless character
      character.strength.nil? || character.strength.zero?
    end

    def missing_class?
      character&.character_class.blank?
    end

    def missing_race?
      character&.race.blank?
    end

    def missing_background?
      character&.background.blank?
    end

    def character_complete?
      !missing_ability_scores? && !missing_class? && !missing_race?
    end

    def has_starting_equipment?
      return false unless character
      inventory = character.character_inventory
      inventory&.inventory_items&.count.to_i > 0
    end

    def ability_scores_unassigned?
      missing_ability_scores?
    end

    def ability_scores_assigned?
      !missing_ability_scores?
    end

    def ability_scores_partially_assigned?
      return false unless character
      assigned = [
        character.strength,
        character.dexterity,
        character.constitution,
        character.intelligence,
        character.wisdom,
        character.charisma
      ].compact.count
      assigned > 0 && assigned < 6
    end

    def unassigned_abilities
      return [] unless character
      abilities = []
      abilities << 'STR' if character.strength.nil? || character.strength.zero?
      abilities << 'DEX' if character.dexterity.nil? || character.dexterity.zero?
      abilities << 'CON' if character.constitution.nil? || character.constitution.zero?
      abilities << 'INT' if character.intelligence.nil? || character.intelligence.zero?
      abilities << 'WIS' if character.wisdom.nil? || character.wisdom.zero?
      abilities << 'CHA' if character.charisma.nil? || character.charisma.zero?
      abilities
    end

    # Combat state checks
    def in_combat?
      session&.mode == 'combat'
    end

    def has_action?
      return true unless character
      tracker = character.character_combat_tracker
      tracker&.action_available? != false
    end

    def has_bonus_action?
      return true unless character
      tracker = character.character_combat_tracker
      tracker&.has_bonus_action? != false
    end

    def has_movement_remaining?
      return true unless character
      tracker = character.character_combat_tracker
      return true unless tracker
      (tracker.remaining_movement || 0) > 0
    end

    def all_actions_used?
      !has_action? && !has_bonus_action? && !has_movement_remaining?
    end

    # Class and level checks
    def spellcaster?
      return false unless character
      spellcasting_classes = %w[bard cleric druid paladin ranger sorcerer warlock wizard]
      spellcasting_classes.include?(character.character_class&.downcase)
    end

    def new_spells_available?(level)
      spellcaster? && [2, 3, 5, 7, 9, 11, 13, 15, 17, 19].include?(level)
    end

    def ability_score_improvement_available?(level)
      [4, 8, 12, 16, 19].include?(level)
    end

    # Inventory checks
    def unequipped_weapons?
      return false unless character
      inventory = character.character_inventory
      return false unless inventory

      inventory.inventory_items.where(equipped: false).joins(:item).where(
        items: { item_type: %w[weapon armor] }
      ).exists?
    end

    def unattuned_magic_items?
      return false unless character
      inventory = character.character_inventory
      return false unless inventory

      inventory.inventory_items.where(attuned: false).joins(:item).where(
        items: { rarity: %w[uncommon rare very_rare legendary] }
      ).exists?
    end
  end
end
