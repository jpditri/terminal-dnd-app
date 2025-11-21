# frozen_string_literal: true

module SoloPlay
  # NpcSpawner generates NPCs with personality and combat stats for solo play
  # Handles both narrative NPCs and combat-ready enemies/allies
  class NpcSpawner
    PERSONALITY_TRAITS = [
      'Brave', 'Cautious', 'Curious', 'Greedy', 'Honest', 'Suspicious',
      'Friendly', 'Hostile', 'Nervous', 'Confident', 'Wise', 'Foolish',
      'Generous', 'Selfish', 'Patient', 'Impatient', 'Loyal', 'Fickle'
    ].freeze

    IDEALS = [
      'Justice', 'Freedom', 'Power', 'Knowledge', 'Wealth', 'Honor',
      'Family', 'Community', 'Tradition', 'Change', 'Beauty', 'Survival'
    ].freeze

    FLAWS = [
      'Arrogant', 'Cowardly', 'Dishonest', 'Vengeful', 'Lazy', 'Stubborn',
      'Addicted', 'Paranoid', 'Naive', 'Cruel', 'Jealous', 'Impulsive'
    ].freeze

    NPC_ARCHETYPES = {
      'guard' => { occupation: 'Town Guard', combat_ready: true, level_offset: 0, skills: ['perception', 'intimidation'] },
      'merchant' => { occupation: 'Merchant', combat_ready: false, level_offset: -1, skills: ['persuasion', 'insight'] },
      'innkeeper' => { occupation: 'Innkeeper', combat_ready: false, level_offset: -2, skills: ['insight', 'performance'] },
      'priest' => { occupation: 'Priest', combat_ready: false, level_offset: 0, skills: ['religion', 'medicine'] },
      'thug' => { occupation: 'Thug', combat_ready: true, level_offset: -1, skills: ['intimidation', 'athletics'] },
      'noble' => { occupation: 'Noble', combat_ready: false, level_offset: 1, skills: ['persuasion', 'history'] },
      'scout' => { occupation: 'Scout', combat_ready: true, level_offset: 0, skills: ['perception', 'stealth', 'survival'] },
      'mage' => { occupation: 'Mage', combat_ready: true, level_offset: 1, skills: ['arcana', 'investigation'] },
      'bandit' => { occupation: 'Bandit', combat_ready: true, level_offset: -1, skills: ['stealth', 'deception'] },
      'blacksmith' => { occupation: 'Blacksmith', combat_ready: false, level_offset: 0, skills: ['athletics', 'investigation'] }
    }.freeze

    def initialize(campaign)
      @campaign = campaign
    end

    # Spawn NPC when player enters a new scene/location
    def spawn_for_scene_entry(scene:, environment:, character_level:)
      archetype = determine_archetype_for_scene(scene, environment)
      npc = create_npc_from_archetype(archetype, character_level)

      # Generate context-appropriate personality
      npc.backstory = generate_scene_backstory(scene, environment, npc.occupation)
      npc.importance_level = calculate_importance(scene, archetype)
      npc.save!

      npc
    end

    # Spawn NPC for narrative purposes (mentioned by DM)
    def spawn_for_narrative(role:, name:, description:, importance:)
      npc = Npc.new(
        campaign: @campaign,
        name: name,
        occupation: role,
        age: rand(18..70),
        importance_level: importance
      )

      personality = generate_personality(occupation: role)
      npc.assign_attributes(personality)

      # Parse description for hints about stats
      npc.backstory = description
      assign_stats(npc, type: infer_archetype_from_role(role), character_level: 1, combat_ready: false)

      npc.save!
      npc
    end

    # Spawn NPC for random encounter
    def spawn_for_random_encounter(encounter_type:, terrain:, character_level:)
      archetype = determine_archetype_for_encounter(encounter_type, terrain)
      npc = create_npc_from_archetype(archetype, character_level)

      npc.backstory = generate_encounter_backstory(encounter_type, terrain)
      npc.importance_level = 'minor'
      npc.status = encounter_type == 'hostile' ? 'hostile' : 'neutral'
      npc.save!

      npc
    end

    # Spawn NPC in response to player action
    def spawn_for_player_action(action:, context:, target:)
      archetype = determine_archetype_for_action(action, context)
      npc = create_npc_from_archetype(archetype, 1)

      npc.backstory = "Appeared in response to #{action}"
      npc.importance_level = 'minor'
      npc.save!

      npc
    end

    # Spawn NPC for quest objective
    def spawn_for_quest_objective(quest_id:, objective:, npc_role:, name:)
      npc = Npc.new(
        campaign: @campaign,
        name: name,
        occupation: npc_role,
        age: rand(18..70),
        importance_level: 'major'
      )

      personality = generate_personality(occupation: npc_role)
      npc.assign_attributes(personality)
      npc.backstory = generate_quest_backstory(quest_id, objective, npc_role)

      assign_stats(npc, type: infer_archetype_from_role(npc_role), character_level: 3, combat_ready: true)
      npc.save!
      npc
    end

    # Generate complete personality profile
    def generate_personality(occupation: nil)
      {
        personality_traits: Array.new(2) { PERSONALITY_TRAITS.sample }.join(', '),
        ideals: IDEALS.sample,
        bonds: generate_bond(occupation),
        flaws: FLAWS.sample,
        voice_style: generate_voice_style,
        speech_patterns: generate_speech_pattern(occupation),
        motivations: generate_motivation(occupation),
        secrets: generate_secret
      }
    end

    # Assign D&D 5e stats based on archetype and level
    def assign_stats(npc, type: 'commoner', character_level: 1, combat_ready: false)
      archetype = NPC_ARCHETYPES[type] || NPC_ARCHETYPES['guard']
      effective_level = [character_level + archetype[:level_offset], 1].max

      # Generate ability scores based on archetype
      stats = generate_ability_scores(type, effective_level)
      npc.assign_attributes(stats)

      # Calculate HP
      constitution_mod = ((stats[:constitution] - 10) / 2).floor
      hit_dice_count = effective_level
      avg_roll = 5 # Average d8 roll
      max_hp = (avg_roll + constitution_mod) * hit_dice_count

      npc.level = effective_level
      npc.max_hit_points = [max_hp, 1].max
      npc.hit_points = npc.max_hit_points
      npc.hit_dice = "#{hit_dice_count}d8"

      # Calculate AC (10 + DEX modifier + armor bonus)
      dex_mod = ((stats[:dexterity] - 10) / 2).floor
      armor_bonus = combat_ready ? (type == 'mage' ? 0 : 3) : 0
      npc.armor_class = 10 + dex_mod + armor_bonus

      # Proficiency bonus
      npc.proficiency_bonus = ((effective_level - 1) / 4) + 2

      # Assign skill proficiencies
      if archetype[:skills]
        skill_hash = {}
        archetype[:skills].each do |skill|
          skill_hash[skill] = npc.proficiency_bonus
        end
        npc.skills = skill_hash
      end

      # Speed
      npc.speed = 30

      # Challenge rating (approximate)
      npc.challenge_rating = effective_level / 2.0
    end

    # Create combat participant for this NPC
    def create_combat_participant(npc:, combat:, stats: nil, hostile: true)
      assign_stats(npc, stats) if stats

      CombatParticipant.create!(
        combat: combat,
        npc: npc
      )
    end

    # Load NPC template (for rapid generation)
    def load_npc_template(template_type)
      archetype = NPC_ARCHETYPES[template_type]
      return nil unless archetype

      {
        occupation: archetype[:occupation],
        combat_ready: archetype[:combat_ready],
        level_offset: archetype[:level_offset],
        skills: archetype[:skills]
      }
    end

    # Apply template to NPC
    def apply_template(npc, template)
      npc.occupation = template[:occupation]
      personality = generate_personality(occupation: template[:occupation])
      npc.assign_attributes(personality)
    end

    private

    def create_npc_from_archetype(archetype, character_level)
      template = NPC_ARCHETYPES[archetype]

      npc = Npc.new(
        campaign: @campaign,
        name: generate_name,
        age: rand(18..70)
      )

      personality = generate_personality(occupation: template[:occupation])
      npc.assign_attributes(personality)
      npc.occupation = template[:occupation]

      assign_stats(npc, type: archetype, character_level: character_level, combat_ready: template[:combat_ready])

      npc
    end

    def generate_ability_scores(archetype, level)
      # Base ability scores based on archetype
      case archetype
      when 'guard', 'thug', 'bandit'
        # STR/CON focused
        { strength: 14 + (level / 4), dexterity: 12, constitution: 13 + (level / 4),
          intelligence: 10, wisdom: 11, charisma: 10 }
      when 'scout'
        # DEX/WIS focused
        { strength: 11, dexterity: 15 + (level / 4), constitution: 12,
          intelligence: 10, wisdom: 14 + (level / 4), charisma: 10 }
      when 'mage'
        # INT focused
        { strength: 8, dexterity: 13, constitution: 11,
          intelligence: 16 + (level / 4), wisdom: 12, charisma: 11 }
      when 'priest'
        # WIS focused
        { strength: 10, dexterity: 10, constitution: 12,
          intelligence: 11, wisdom: 16 + (level / 4), charisma: 13 }
      when 'merchant', 'noble'
        # CHA focused
        { strength: 9, dexterity: 11, constitution: 10,
          intelligence: 12, wisdom: 11, charisma: 15 + (level / 4) }
      else
        # Commoner stats
        { strength: 10, dexterity: 10, constitution: 10,
          intelligence: 10, wisdom: 10, charisma: 10 }
      end
    end

    def determine_archetype_for_scene(scene, environment)
      case environment.downcase
      when /tavern|inn/ then 'innkeeper'
      when /shop|market/ then 'merchant'
      when /temple|church/ then 'priest'
      when /guard|gate/ then 'guard'
      when /road|path/ then ['scout', 'bandit'].sample
      else 'merchant'
      end
    end

    def determine_archetype_for_encounter(encounter_type, terrain)
      if encounter_type == 'hostile'
        ['thug', 'bandit', 'scout'].sample
      else
        ['merchant', 'scout', 'priest'].sample
      end
    end

    def determine_archetype_for_action(action, context)
      case action.downcase
      when /attack|fight/ then 'guard'
      when /buy|sell|trade/ then 'merchant'
      when /heal|pray/ then 'priest'
      else 'guard'
      end
    end

    def infer_archetype_from_role(role)
      role_lower = role.downcase
      NPC_ARCHETYPES.keys.each do |archetype|
        return archetype if role_lower.include?(archetype) || archetype.include?(role_lower)
      end
      'guard' # Default
    end

    def calculate_importance(scene, archetype)
      archetype.in?(['noble', 'priest', 'mage']) ? 'major' : 'minor'
    end

    def generate_name
      first_names = ['Aldric', 'Bran', 'Cedric', 'Dana', 'Elara', 'Finn', 'Gwen', 'Holt',
                     'Iris', 'Jax', 'Kara', 'Len', 'Mira', 'Nyx', 'Orin', 'Pax', 'Quinn']
      last_names = ['Stone', 'Wood', 'Iron', 'Swift', 'Bright', 'Dark', 'Strong', 'Wise',
                    'Bold', 'Fair', 'Gray', 'Storm', 'River', 'Hill']
      "#{first_names.sample} #{last_names.sample}"
    end

    def generate_bond(occupation)
      bonds = [
        "Owes a debt to a mysterious patron",
        "Seeks revenge for a past wrong",
        "Protecting a secret that could destroy them",
        "Loyal to their #{occupation || 'profession'} above all else",
        "Has a family member in danger",
        "Dreams of leaving this life behind"
      ]
      bonds.sample
    end

    def generate_voice_style
      ['Gruff', 'Soft-spoken', 'Booming', 'Whispery', 'Melodious', 'Harsh', 'Warm', 'Cold'].sample
    end

    def generate_speech_pattern(occupation)
      patterns = {
        'guard' => 'Direct and authoritative',
        'merchant' => 'Persuasive with frequent pauses to calculate',
        'priest' => 'Calm with religious references',
        'mage' => 'Precise with arcane terminology',
        'innkeeper' => 'Friendly and gossipy'
      }
      patterns[occupation&.downcase] || 'Casual and informal'
    end

    def generate_motivation(occupation)
      motivations = {
        'guard' => 'Maintain order and protect citizens',
        'merchant' => 'Maximize profit while maintaining reputation',
        'priest' => 'Spread faith and help the needy',
        'mage' => 'Pursue knowledge and magical mastery',
        'thug' => 'Earn easy money through intimidation'
      }
      motivations[occupation&.downcase] || 'Survive and provide for family'
    end

    def generate_secret
      secrets = [
        "Once failed to save someone important",
        "Has a hidden magical ability",
        "Knows about a buried treasure",
        "Working as a spy for someone",
        "Hiding from a dangerous enemy",
        "Not who they claim to be"
      ]
      secrets.sample
    end

    def generate_scene_backstory(scene, environment, occupation)
      "A #{occupation} who has worked in the #{environment} for several years. #{generate_bond(occupation)}."
    end

    def generate_encounter_backstory(encounter_type, terrain)
      "Encountered while traveling through #{terrain}. #{encounter_type.capitalize} intentions."
    end

    def generate_quest_backstory(quest_id, objective, role)
      "Key figure in quest objective: #{objective}. Their role as #{role} makes them essential to the mission."
    end
  end
end
