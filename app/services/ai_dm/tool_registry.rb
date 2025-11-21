# frozen_string_literal: true

module AiDm
  # Registry of all tools available to the AI DM
  # Tools are organized by category and integrate with existing heretical-web-app services
  class ToolRegistry
    TOOLS = {
      # ========================================
      # CHARACTER MANAGEMENT TOOLS
      # ========================================

      create_character: {
        name: 'create_character',
        description: 'Create a new character with specified attributes',
        category: :character,
        parameters: {
          name: { type: 'string', required: true, description: 'Character name' },
          race: { type: 'string', required: true, description: 'Character race (e.g., Human, Elf, Dwarf)' },
          character_class: { type: 'string', required: true, description: 'Character class (e.g., Fighter, Wizard)' },
          background: { type: 'string', required: false, description: 'Character background' },
          ability_scores: { type: 'object', required: false, description: 'Ability scores hash' }
        },
        approval_required: false,
        immediate: true
      },

      set_ability_score: {
        name: 'set_ability_score',
        description: 'Set a specific ability score for a character',
        category: :character,
        parameters: {
          character_id: { type: 'integer', required: false, description: 'Character ID (defaults to session character)' },
          ability: { type: 'string', enum: %w[strength dexterity constitution intelligence wisdom charisma], required: true },
          value: { type: 'integer', min: 1, max: 30, required: true }
        },
        approval_required: true,
        immediate: false
      },

      grant_item: {
        name: 'grant_item',
        description: 'Add an item to character inventory',
        category: :character,
        parameters: {
          character_id: { type: 'integer', required: false },
          item_name: { type: 'string', required: true },
          quantity: { type: 'integer', default: 1 },
          equipped: { type: 'boolean', default: false },
          properties: { type: 'object', required: false, description: 'Item properties (type, weight, value, etc.)' }
        },
        approval_required: false,
        immediate: true
      },

      grant_skill_proficiency: {
        name: 'grant_skill_proficiency',
        description: 'Grant proficiency or expertise in a skill',
        category: :character,
        parameters: {
          character_id: { type: 'integer', required: false },
          skill: { type: 'string', required: true },
          expertise: { type: 'boolean', default: false }
        },
        approval_required: true,
        immediate: false
      },

      modify_backstory: {
        name: 'modify_backstory',
        description: 'Update or append to character backstory',
        category: :character,
        parameters: {
          character_id: { type: 'integer', required: false },
          new_backstory: { type: 'string', required: true },
          append: { type: 'boolean', default: false, description: 'Append to existing backstory instead of replacing' }
        },
        approval_required: true,
        immediate: false
      },

      level_up: {
        name: 'level_up',
        description: 'Advance character to next level',
        category: :character,
        parameters: {
          character_id: { type: 'integer', required: false },
          hp_choice: { type: 'string', enum: %w[roll average], default: 'average' },
          skip_xp_check: { type: 'boolean', default: false }
        },
        approval_required: true,
        immediate: false
      },

      # ========================================
      # COMBAT TOOLS - Delegate to existing services
      # ========================================

      start_combat: {
        name: 'start_combat',
        description: 'Initiate combat with specified enemies',
        category: :combat,
        parameters: {
          enemies: { type: 'array', required: true, description: 'Array of enemy objects with name, hp, ac, initiative_bonus' }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'SoloPlay::CombatInitiator'
      },

      next_turn: {
        name: 'next_turn',
        description: 'Advance to the next turn in combat',
        category: :combat,
        parameters: {},
        approval_required: false,
        immediate: true,
        delegates_to: 'SoloPlay::CombatManager'
      },

      use_action: {
        name: 'use_action',
        description: 'Mark action as used for this turn',
        category: :combat,
        parameters: {
          action_type: { type: 'string', required: true, description: 'Type of action taken' }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      use_bonus_action: {
        name: 'use_bonus_action',
        description: 'Mark bonus action as used for this turn',
        category: :combat,
        parameters: {},
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      use_reaction: {
        name: 'use_reaction',
        description: 'Mark reaction as used for this round',
        category: :combat,
        parameters: {},
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      use_movement: {
        name: 'use_movement',
        description: 'Use movement speed',
        category: :combat,
        parameters: {
          feet: { type: 'integer', required: true, description: 'Number of feet to move' }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      apply_damage: {
        name: 'apply_damage',
        description: 'Apply damage to a combat participant',
        category: :combat,
        parameters: {
          participant_id: { type: 'integer', required: true },
          amount: { type: 'integer', required: true },
          damage_type: { type: 'string', default: 'untyped' },
          reason: { type: 'string', required: true }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'SoloPlay::CombatManager'
      },

      apply_healing: {
        name: 'apply_healing',
        description: 'Apply healing to a combat participant',
        category: :combat,
        parameters: {
          participant_id: { type: 'integer', required: true },
          amount: { type: 'integer', required: true },
          reason: { type: 'string', required: true }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'SoloPlay::CombatManager'
      },

      roll_initiative: {
        name: 'roll_initiative',
        description: 'Roll initiative for character',
        category: :combat,
        parameters: {
          advantage: { type: 'boolean', default: false },
          disadvantage: { type: 'boolean', default: false }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      end_combat: {
        name: 'end_combat',
        description: 'End the current combat encounter',
        category: :combat,
        parameters: {
          outcome: { type: 'string', enum: %w[victory defeat retreat], required: false }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'SoloPlay::CombatManager'
      },

      # ========================================
      # CONDITIONS & EFFECTS TOOLS
      # ========================================

      apply_condition: {
        name: 'apply_condition',
        description: 'Apply a condition to a character',
        category: :conditions,
        parameters: {
          character_id: { type: 'integer', required: false },
          condition: { type: 'string', required: true, description: 'Condition name (e.g., poisoned, frightened)' },
          duration: { type: 'string', required: false, description: 'Duration (rounds, minutes, or until removed)' },
          source: { type: 'string', required: false, description: 'Source of the condition' }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      remove_condition: {
        name: 'remove_condition',
        description: 'Remove a condition from a character',
        category: :conditions,
        parameters: {
          character_id: { type: 'integer', required: false },
          condition: { type: 'string', required: true }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      apply_exhaustion: {
        name: 'apply_exhaustion',
        description: 'Add or remove exhaustion levels',
        category: :conditions,
        parameters: {
          character_id: { type: 'integer', required: false },
          levels: { type: 'integer', required: true, description: 'Levels to add (positive) or remove (negative)' },
          reason: { type: 'string', required: true }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      death_save: {
        name: 'death_save',
        description: 'Roll a death saving throw',
        category: :conditions,
        parameters: {
          character_id: { type: 'integer', required: false },
          advantage: { type: 'boolean', default: false },
          disadvantage: { type: 'boolean', default: false }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      # ========================================
      # ECONOMY & PROGRESSION TOOLS
      # ========================================

      grant_gold: {
        name: 'grant_gold',
        description: 'Add or remove gold from character',
        category: :economy,
        parameters: {
          character_id: { type: 'integer', required: false },
          amount: { type: 'integer', required: true, description: 'Amount (positive to add, negative to remove)' },
          reason: { type: 'string', required: true }
        },
        approval_required: false,
        immediate: true
      },

      grant_experience: {
        name: 'grant_experience',
        description: 'Award experience points',
        category: :economy,
        parameters: {
          character_id: { type: 'integer', required: false },
          amount: { type: 'integer', required: true },
          reason: { type: 'string', required: true }
        },
        approval_required: false,
        immediate: true
      },

      # ========================================
      # QUEST TOOLS
      # ========================================

      create_quest: {
        name: 'create_quest',
        description: 'Create a new quest with objectives and rewards',
        category: :quest,
        parameters: {
          title: { type: 'string', required: true },
          description: { type: 'string', required: true },
          objectives: { type: 'array', required: false, description: 'Array of objective objects' },
          gold_reward: { type: 'integer', default: 0 },
          experience_reward: { type: 'integer', default: 0 },
          item_rewards: { type: 'array', default: [] },
          difficulty: { type: 'string', enum: %w[trivial easy medium hard deadly], default: 'medium' }
        },
        approval_required: false,
        immediate: true
      },

      complete_objective: {
        name: 'complete_objective',
        description: 'Mark a quest objective as complete',
        category: :quest,
        parameters: {
          quest_id: { type: 'integer', required: true },
          objective_id: { type: 'integer', required: true },
          partial_progress: { type: 'integer', required: false, description: 'Partial progress amount' }
        },
        approval_required: false,
        immediate: true
      },

      # ========================================
      # NPC & WORLD TOOLS
      # ========================================

      spawn_npc: {
        name: 'spawn_npc',
        description: 'Create an NPC in the current scene',
        category: :world,
        parameters: {
          name: { type: 'string', required: true },
          personality_traits: { type: 'array', required: false },
          disposition: { type: 'string', enum: %w[friendly neutral hostile], default: 'neutral' },
          occupation: { type: 'string', required: false },
          location: { type: 'string', required: false }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'SoloPlay::NpcSpawner'
      },

      npc_speak: {
        name: 'npc_speak',
        description: 'Generate NPC dialogue based on personality and context',
        category: :world,
        parameters: {
          npc_id: { type: 'integer', required: true, description: 'ID of the NPC to speak' },
          player_input: { type: 'string', required: false, description: 'What the player said to the NPC' },
          greeting: { type: 'boolean', default: false, description: 'Generate a greeting' },
          topic: { type: 'string', required: false, description: 'Topic to discuss or ask about' },
          quest_request: { type: 'boolean', default: false, description: 'NPC offers a quest' },
          location: { type: 'string', required: false, description: 'Current location' },
          time_of_day: { type: 'string', required: false, description: 'Time of day context' }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'SoloPlay::NpcDialogueService'
      },

      npc_react: {
        name: 'npc_react',
        description: 'Generate NPC reaction to player action or event',
        category: :world,
        parameters: {
          npc_id: { type: 'integer', required: true, description: 'ID of the NPC reacting' },
          action: { type: 'string', required: true, description: 'What action occurred' },
          outcome: { type: 'string', required: false, description: 'Outcome of the action' },
          location: { type: 'string', required: false, description: 'Current location' }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'SoloPlay::NpcDialogueService'
      },

      # ========================================
      # FACTION TOOLS
      # ========================================

      create_faction: {
        name: 'create_faction',
        description: 'Create a new faction in the world (guild, kingdom, criminal organization, etc.)',
        category: :world,
        parameters: {
          name: { type: 'string', required: true, description: 'Name of the faction' },
          faction_type: {
            type: 'string',
            required: false,
            enum: %w[government guild religious military criminal merchant tribal cult noble academic],
            description: 'Type of organization'
          },
          description: { type: 'string', required: false, description: 'Overview of the faction' },
          power_level: {
            type: 'integer',
            required: false,
            default: 5,
            min: 1,
            max: 10,
            description: 'Political/military power (1=local, 5=regional, 10=national)'
          },
          alignment: {
            type: 'string',
            required: false,
            enum: %w[lawful_good neutral_good chaotic_good lawful_neutral true_neutral chaotic_neutral lawful_evil neutral_evil chaotic_evil],
            description: 'Moral alignment'
          },
          goals: { type: 'object', required: false, description: 'Faction goals and motivations' },
          territory: { type: 'string', required: false, description: 'Controlled territory or headquarters' }
        },
        approval_required: false,
        immediate: true
      },

      adjust_faction_reputation: {
        name: 'adjust_faction_reputation',
        description: 'Modify character reputation with a faction based on actions',
        category: :world,
        parameters: {
          faction_id: { type: 'integer', required: true, description: 'ID of the faction' },
          character_id: { type: 'integer', required: true, description: 'ID of the character' },
          amount: {
            type: 'integer',
            required: true,
            min: -50,
            max: 50,
            description: 'Reputation change (-50 to +50, negative=worse, positive=better)'
          },
          reason: { type: 'string', required: true, description: 'Why reputation changed' }
        },
        approval_required: false,
        immediate: true
      },

      # ========================================
      # GAME STATE TOOLS
      # ========================================

      roll_dice: {
        name: 'roll_dice',
        description: 'Roll dice and optionally apply the result',
        category: :game_state,
        parameters: {
          dice_expression: { type: 'string', required: true, description: 'Dice notation (e.g., 2d6+3, 1d20)' },
          purpose: { type: 'string', required: true, description: 'What the roll is for' },
          dc: { type: 'integer', required: false, description: 'Difficulty class for success/fail' },
          advantage: { type: 'boolean', default: false },
          disadvantage: { type: 'boolean', default: false }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'DiceRoller'
      },

      # ========================================
      # D&D 5E MECHANICS TOOLS - Generated from MDSL
      # ========================================

      make_skill_check: {
        name: 'make_skill_check',
        description: 'Perform a D&D 5e skill check with proficiency and advantage/disadvantage support. Use for Athletics, Acrobatics, Stealth, Perception, Investigation, Persuasion, etc.',
        category: :game_state,
        parameters: {
          character_id: { type: 'integer', required: true, description: 'Character performing the check' },
          skill: {
            type: 'string',
            required: true,
            enum: %w[athletics acrobatics sleight_of_hand stealth arcana history investigation nature religion animal_handling insight medicine perception survival deception intimidation performance persuasion],
            description: 'Skill name (e.g., athletics, perception, stealth)'
          },
          dc: { type: 'integer', required: true, min: 1, max: 30, description: 'Difficulty Class (5=trivial, 10=easy, 15=medium, 20=hard, 25=very hard, 30=nearly impossible)' },
          advantage: { type: 'boolean', default: false, description: 'Roll with advantage (roll twice, take higher)' },
          disadvantage: { type: 'boolean', default: false, description: 'Roll with disadvantage (roll twice, take lower)' },
          modifier_override: { type: 'integer', required: false, description: 'Override calculated modifier' }
        },
        approval_required: false,
        immediate: true
      },

      make_ability_check: {
        name: 'make_ability_check',
        description: 'Perform a raw ability check (Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma) without skill proficiency',
        category: :game_state,
        parameters: {
          character_id: { type: 'integer', required: true },
          ability: {
            type: 'string',
            required: true,
            enum: %w[strength dexterity constitution intelligence wisdom charisma],
            description: 'Ability score (strength, dexterity, constitution, intelligence, wisdom, charisma)'
          },
          dc: { type: 'integer', required: true, min: 1, max: 30 },
          advantage: { type: 'boolean', default: false },
          disadvantage: { type: 'boolean', default: false }
        },
        approval_required: false,
        immediate: true
      },

      make_saving_throw: {
        name: 'make_saving_throw',
        description: 'Perform a D&D 5e saving throw to resist spells, traps, poisons, or environmental hazards',
        category: :game_state,
        parameters: {
          character_id: { type: 'integer', required: true },
          save_type: {
            type: 'string',
            required: true,
            enum: %w[strength dexterity constitution intelligence wisdom charisma STR DEX CON INT WIS CHA],
            description: 'Save type (STR, DEX, CON, INT, WIS, or CHA)'
          },
          dc: { type: 'integer', required: true, min: 1, max: 30 },
          advantage: { type: 'boolean', default: false },
          disadvantage: { type: 'boolean', default: false },
          source: { type: 'string', required: false, description: 'What caused the save (e.g., Fireball spell, poison, trap)' }
        },
        approval_required: false,
        immediate: true
      },

      make_attack: {
        name: 'make_attack',
        description: 'Make an attack roll and damage roll for D&D 5e combat (melee, ranged, or spell attack)',
        category: :game_state,
        parameters: {
          attacker_id: { type: 'integer', required: true, description: 'Character making the attack' },
          target_id: { type: 'integer', required: true, description: 'Character being attacked' },
          attack_type: {
            type: 'string',
            required: true,
            enum: %w[melee ranged spell],
            description: 'Attack type (melee, ranged, or spell)'
          },
          weapon_name: { type: 'string', default: 'Unarmed Strike', description: 'Weapon or spell name' },
          damage_dice: { type: 'string', default: '1d4', description: 'Damage dice notation (e.g., 1d8, 2d6)' },
          damage_type: {
            type: 'string',
            default: 'bludgeoning',
            enum: %w[bludgeoning piercing slashing acid cold fire force lightning necrotic poison psychic radiant thunder],
            description: 'Damage type'
          },
          advantage: { type: 'boolean', default: false },
          disadvantage: { type: 'boolean', default: false }
        },
        approval_required: false,
        immediate: true
      },

      cast_spell: {
        name: 'cast_spell',
        description: 'Cast a D&D 5e spell with spell attack or saving throw. Simplified spell system - for full implementation, use specific spell tools',
        category: :game_state,
        parameters: {
          caster_id: { type: 'integer', required: true, description: 'Character casting the spell' },
          spell_name: { type: 'string', required: true, description: 'Name of the spell' },
          target_ids: {
            type: 'array',
            required: true,
            description: 'Array of character IDs to target (can be single or multiple)'
          },
          spell_level: { type: 'integer', default: 1, min: 0, max: 9, description: 'Spell level (0-9, 0 for cantrips)' },
          spell_save_dc: { type: 'integer', required: false, description: 'Spell save DC (auto-calculated if not provided)' },
          upcasted: { type: 'boolean', default: false, description: 'Whether spell was cast at higher level' }
        },
        approval_required: false,
        immediate: true
      },

      validate_action: {
        name: 'validate_action',
        description: 'Check if an action is valid according to D&D 5e rules',
        category: :game_state,
        parameters: {
          action_type: { type: 'string', required: true },
          action_params: { type: 'object', required: false }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'SoloPlay::ActionValidator'
      },

      explain_rule: {
        name: 'explain_rule',
        description: 'Get explanation of a D&D 5e rule',
        category: :game_state,
        parameters: {
          topic: { type: 'string', required: true, description: 'Rule topic (condition, damage type, weapon property, etc.)' },
          specific: { type: 'string', required: false, description: 'Specific item to explain' }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'Multiplayer::RulesExplainer'
      },

      rewind_turn: {
        name: 'rewind_turn',
        description: 'Undo recent actions and revert game state',
        category: :game_state,
        parameters: {
          turns_back: { type: 'integer', default: 1, description: 'Number of turns to rewind' },
          reason: { type: 'string', required: true }
        },
        approval_required: true,
        immediate: false
      },

      adjust_hp: {
        name: 'adjust_hp',
        description: 'Directly adjust character HP (outside of combat)',
        category: :game_state,
        parameters: {
          character_id: { type: 'integer', required: false },
          delta: { type: 'integer', required: true, description: 'HP change (positive for heal, negative for damage)' },
          reason: { type: 'string', required: true }
        },
        approval_required: false,
        immediate: true
      },

      short_rest: {
        name: 'short_rest',
        description: 'Take a short rest (1 hour)',
        category: :game_state,
        parameters: {
          character_id: { type: 'integer', required: false },
          hit_dice_to_spend: { type: 'integer', default: 0 }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      long_rest: {
        name: 'long_rest',
        description: 'Take a long rest (8 hours)',
        category: :game_state,
        parameters: {
          character_id: { type: 'integer', required: false }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'CharacterCombatTracker'
      },

      # ========================================
      # HOMEBREW & TREASURE TOOLS
      # ========================================

      create_homebrew_item: {
        name: 'create_homebrew_item',
        description: 'Create a custom magic item with specified properties and rarity. Item will be queued for player approval before being added.',
        category: :homebrew,
        parameters: {
          name: { type: 'string', required: true, description: 'Item name (e.g., "Sword of Flame", "Amulet of the Moon")' },
          description: { type: 'string', required: true, description: 'Full item description including appearance and lore' },
          rarity: {
            type: 'string',
            required: true,
            enum: %w[common uncommon rare very_rare legendary artifact],
            description: 'Item rarity (common, uncommon, rare, very_rare, legendary, artifact)'
          },
          item_type: {
            type: 'string',
            required: true,
            enum: %w[weapon armor potion scroll wand staff ring wondrous],
            description: 'Type of item'
          },
          requires_attunement: { type: 'boolean', default: false, description: 'Whether item requires attunement' },
          attunement_requirements: {
            type: 'object',
            required: false,
            description: 'Attunement restrictions (classes, alignment, etc.)'
          },
          properties: {
            type: 'object',
            required: false,
            description: 'Item properties (attack_bonus, damage_dice, ac_bonus, ability_bonuses, spell_effects, etc.)'
          },
          cursed: { type: 'boolean', default: false, description: 'Whether item is cursed' },
          grant_to_character: { type: 'boolean', default: true, description: 'Grant item to character after approval' }
        },
        approval_required: true,
        immediate: false,
        delegates_to: 'Homebrew::ItemCreator'
      },

      generate_treasure: {
        name: 'generate_treasure',
        description: 'Generate treasure from loot table or by Challenge Rating using DMG treasure tables. Can grant gold, items, or both.',
        category: :treasure,
        parameters: {
          method: {
            type: 'string',
            required: true,
            enum: %w[loot_table challenge_rating],
            description: 'Generation method (loot_table or challenge_rating)'
          },
          loot_table_id: {
            type: 'integer',
            required: false,
            description: 'ID of loot table to roll (required if method is loot_table)'
          },
          challenge_rating: {
            type: 'number',
            required: false,
            description: 'CR for treasure generation (required if method is challenge_rating)'
          },
          grant_to_character: { type: 'boolean', default: true, description: 'Automatically grant treasure to character' }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'Treasure::Generator'
      },

      create_loot_table: {
        name: 'create_loot_table',
        description: 'Create a loot table with weighted random entries. Useful for recurring treasure drops.',
        category: :treasure,
        parameters: {
          name: { type: 'string', required: true, description: 'Loot table name (e.g., "Goblin Loot", "Dragon Hoard")' },
          description: { type: 'string', required: false, description: 'When/where this table is used' },
          entries: {
            type: 'array',
            required: true,
            description: 'Array of loot entries with treasure_type, weight, quantity_dice, and optional item_id'
          }
        },
        approval_required: false,
        immediate: true,
        delegates_to: 'Treasure::LootTableBuilder'
      },

      grant_homebrew_item: {
        name: 'grant_homebrew_item',
        description: 'Add a homebrew item from the collection to character inventory',
        category: :homebrew,
        parameters: {
          character_id: { type: 'integer', required: false },
          homebrew_item_id: { type: 'integer', required: true, description: 'ID of the homebrew item to grant' },
          quantity: { type: 'integer', default: 1 },
          identified: { type: 'boolean', default: false, description: 'Whether item properties are known' },
          attuned: { type: 'boolean', default: false, description: 'Whether item is already attuned' }
        },
        approval_required: false,
        immediate: true
      },

      attune_item: {
        name: 'attune_item',
        description: 'Attune character to a magic item that requires attunement',
        category: :character,
        parameters: {
          character_id: { type: 'integer', required: false },
          inventory_item_id: { type: 'integer', required: true, description: 'ID of inventory item to attune' }
        },
        approval_required: false,
        immediate: true
      },

      identify_item: {
        name: 'identify_item',
        description: 'Reveal the properties of an unidentified magic item',
        category: :character,
        parameters: {
          inventory_item_id: { type: 'integer', required: true, description: 'ID of inventory item to identify' },
          method: {
            type: 'string',
            enum: %w[spell short_rest examination],
            default: 'spell',
            description: 'How item was identified'
          }
        },
        approval_required: false,
        immediate: true
      },

      remove_item: {
        name: 'remove_item',
        description: 'Remove an item from character inventory',
        category: :character,
        parameters: {
          character_id: { type: 'integer', required: false },
          inventory_item_id: { type: 'integer', required: true },
          quantity: { type: 'integer', default: 1 },
          reason: { type: 'string', required: true, description: 'Why item was removed (sold, destroyed, given away, etc.)' }
        },
        approval_required: false,
        immediate: true
      },

      create_homebrew_spell: {
        name: 'create_homebrew_spell',
        description: 'Create a custom spell with specified level, school, and effects. Spell will be queued for player approval.',
        category: :homebrew,
        parameters: {
          name: { type: 'string', required: true },
          description: { type: 'string', required: true },
          level: { type: 'integer', required: true, min: 0, max: 9, description: 'Spell level (0 for cantrips)' },
          school: {
            type: 'string',
            required: true,
            enum: %w[abjuration conjuration divination enchantment evocation illusion necromancy transmutation]
          },
          casting_time: { type: 'string', required: true, description: 'e.g., "1 action", "1 bonus action", "1 minute"' },
          range: { type: 'string', required: true, description: 'e.g., "Self", "Touch", "60 feet"' },
          components: { type: 'array', required: true, description: 'Array of V, S, M' },
          duration: { type: 'string', required: true, description: 'e.g., "Instantaneous", "Concentration, up to 1 minute"' },
          damage_dice: { type: 'string', required: false, description: 'Damage dice if applicable' },
          damage_type: { type: 'string', required: false },
          save_type: { type: 'string', required: false, enum: %w[strength dexterity constitution intelligence wisdom charisma] },
          available_to_classes: { type: 'array', required: false, description: 'Which classes can learn this spell' }
        },
        approval_required: true,
        immediate: false,
        delegates_to: 'Homebrew::SpellCreator'
      },

      list_homebrew: {
        name: 'list_homebrew',
        description: 'List all homebrew content created for this campaign',
        category: :homebrew,
        parameters: {
          content_type: {
            type: 'string',
            required: false,
            enum: %w[items spells feats features all],
            default: 'all',
            description: 'Type of homebrew content to list'
          }
        },
        approval_required: false,
        immediate: true
      }
    }.freeze

    class << self
      def get(tool_name)
        TOOLS[tool_name.to_sym]
      end

      def all
        TOOLS
      end

      def by_category(category)
        TOOLS.select { |_, config| config[:category] == category.to_sym }
      end

      def categories
        TOOLS.values.map { |t| t[:category] }.uniq
      end

      def immediate_tools
        TOOLS.select { |_, config| config[:immediate] }
      end

      def approval_required_tools
        TOOLS.select { |_, config| config[:approval_required] }
      end

      # Format tools for Claude API function calling
      def for_claude_api
        TOOLS.map do |name, config|
          {
            name: name.to_s,
            description: config[:description],
            input_schema: {
              type: 'object',
              properties: format_parameters_for_schema(config[:parameters]),
              required: config[:parameters].select { |_, v| v[:required] }.keys.map(&:to_s)
            }
          }
        end
      end

      private

      def format_parameters_for_schema(parameters)
        parameters.transform_values do |param_config|
          schema = { type: param_config[:type] }
          schema[:description] = param_config[:description] if param_config[:description]
          schema[:enum] = param_config[:enum] if param_config[:enum]
          schema[:default] = param_config[:default] if param_config.key?(:default)
          schema[:minimum] = param_config[:min] if param_config[:min]
          schema[:maximum] = param_config[:max] if param_config[:max]
          schema
        end
      end
    end
  end
end
