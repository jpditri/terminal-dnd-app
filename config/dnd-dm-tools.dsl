# D&D AI DM Tools DSL
# Defines the tools available to the AI DM for running Terminal D&D sessions
#
# This DSL generates Ruby code that integrates with the existing ToolExecutor
# and provides D&D 5e mechanics for character interactions.

cli "DndDmTools" do
  version "1.0.0"
  description "D&D 5e AI DM Tool System - Skill checks, ability checks, saving throws, attacks, and spells"
  mode :library  # Generates library code, not a standalone CLI

  # Intent: Dice Rolling Engine
  intent :dice do
    standard_dice %w[d4 d6 d8 d10 d12 d20 d100]

    roll_types do
      # Basic d20 roll with advantage/disadvantage
      roll :d20_check do
        dice "1d20"
        supports_advantage true
        supports_disadvantage true

        mechanics do
          advantage -> { [roll_die(20), roll_die(20)].max }
          disadvantage -> { [roll_die(20), roll_die(20)].min }
          normal -> { roll_die(20) }
        end
      end

      # Damage rolls
      roll :damage do
        variable_dice true
        modifier_from :ability_modifier
        supports_critical true

        mechanics do
          critical -> { (roll_dice(dice_formula) + roll_dice(dice_formula)) + modifier }
          normal -> { roll_dice(dice_formula) + modifier }
        end
      end
    end
  end

  # Intent: D&D 5e Ability System
  intent :abilities do
    ability_scores %w[strength dexterity constitution intelligence wisdom charisma]

    ability_score do
      name :strength
      abbrev "STR"
      modifier_formula -> { (score - 10) / 2 }

      common_checks do
        check :athletics, description: "Physical prowess including climbing, jumping, swimming"
        check :raw_strength, description: "Brute force, lifting, breaking"
      end
    end

    ability_score do
      name :dexterity
      abbrev "DEX"

      common_checks do
        check :acrobatics, description: "Balance, tumbling, dodging"
        check :sleight_of_hand, description: "Pickpocketing, legerdemain"
        check :stealth, description: "Hiding, moving silently"
      end
    end

    ability_score do
      name :constitution
      abbrev "CON"

      common_checks do
        check :endurance, description: "Resisting fatigue, poison, disease"
      end
    end

    ability_score do
      name :intelligence
      abbrev "INT"

      common_checks do
        check :arcana, description: "Knowledge of magic, spells, arcane symbols"
        check :history, description: "Historical events, legends, people"
        check :investigation, description: "Finding clues, deducing conclusions"
        check :nature, description: "Terrain, plants, animals, weather"
        check :religion, description: "Deities, rites, prayers, religious hierarchies"
      end
    end

    ability_score do
      name :wisdom
      abbrev "WIS"

      common_checks do
        check :animal_handling, description: "Calming or training animals"
        check :insight, description: "Determining intentions, reading body language"
        check :medicine, description: "Stabilizing dying, diagnosing illness"
        check :perception, description: "Spotting, hearing, detecting presence"
        check :survival, description: "Tracking, hunting, navigating wilderness"
      end
    end

    ability_score do
      name :charisma
      abbrev "CHA"

      common_checks do
        check :deception, description: "Hiding truth, misleading"
        check :intimidation, description: "Influencing through threats"
        check :performance, description: "Entertaining through music, dance, acting"
        check :persuasion, description: "Influencing through tact, diplomacy"
      end
    end
  end

  # Tool: Make Skill Check
  command "make_skill_check" do
    description "Perform a D&D 5e skill check with proficiency, advantage/disadvantage"

    argument :character_id, required: true, type: :integer, description: "Character performing the check"
    argument :skill, required: true, type: :string, description: "Skill name (athletics, perception, etc.)"
    argument :dc, required: true, type: :integer, description: "Difficulty Class (5=trivial, 30=nearly impossible)"

    option :advantage, type: :boolean, default: false, description: "Roll with advantage (roll twice, take higher)"
    option :disadvantage, type: :boolean, default: false, description: "Roll with disadvantage (roll twice, take lower)"
    option :modifier_override, type: :integer, default: nil, description: "Override calculated modifier"

    validates do
      presence :character_id, :skill, :dc
      range :dc, 1..30
      enum :skill, %w[
        athletics acrobatics sleight_of_hand stealth
        arcana history investigation nature religion
        animal_handling insight medicine perception survival
        deception intimidation performance persuasion
      ]
    end

    execute <<-'RUBY'
      # Get character and skill details
      character = Character.find(params[:character_id])
      skill_name = params[:skill]
      dc = params[:dc]

      # Determine ability and modifier
      ability_map = {
        'athletics' => :strength,
        'acrobatics' => :dexterity,
        'sleight_of_hand' => :dexterity,
        'stealth' => :dexterity,
        'arcana' => :intelligence,
        'history' => :intelligence,
        'investigation' => :intelligence,
        'nature' => :intelligence,
        'religion' => :intelligence,
        'animal_handling' => :wisdom,
        'insight' => :wisdom,
        'medicine' => :wisdom,
        'perception' => :wisdom,
        'survival' => :wisdom,
        'deception' => :charisma,
        'intimidation' => :charisma,
        'performance' => :charisma,
        'persuasion' => :charisma
      }

      ability = ability_map[skill_name]
      ability_modifier = character.send("#{ability}_modifier")

      # Check proficiency (simplified - would check character.proficiencies in real system)
      proficiency_bonus = ((character.level - 1) / 4) + 2
      is_proficient = character.respond_to?(:proficiencies) &&
                      character.proficiencies&.include?(skill_name)

      total_modifier = params[:modifier_override] ||
                       (ability_modifier + (is_proficient ? proficiency_bonus : 0))

      # Roll d20
      if params[:advantage] && params[:disadvantage]
        # Cancel out - normal roll
        roll = DiceRoller.roll('1d20')
      elsif params[:advantage]
        roll1 = DiceRoller.roll('1d20')
        roll2 = DiceRoller.roll('1d20')
        roll = [roll1, roll2].max
      elsif params[:disadvantage]
        roll1 = DiceRoller.roll('1d20')
        roll2 = DiceRoller.roll('1d20')
        roll = [roll1, roll2].min
      else
        roll = DiceRoller.roll('1d20')
      end

      total = roll + total_modifier
      success = total >= dc
      margin = total - dc

      # Determine degree of success
      degree = if roll == 1
                 'critical_failure'
               elsif roll == 20
                 'critical_success'
               elsif margin >= 10
                 'exceptional_success'
               elsif margin >= 5
                 'success_with_style'
               elsif success
                 'success'
               elsif margin >= -5
                 'near_miss'
               else
                 'failure'
               end

      {
        success: success,
        roll: roll,
        modifier: total_modifier,
        total: total,
        dc: dc,
        margin: margin,
        degree: degree,
        skill: skill_name,
        ability: ability,
        proficient: is_proficient,
        advantage_used: params[:advantage],
        disadvantage_used: params[:disadvantage]
      }
    RUBY

    output_format :json

    examples do
      example "Simple perception check",
              command: "make_skill_check 1 perception 15",
              description: "Character 1 makes a DC 15 Perception check"

      example "Stealth with advantage",
              command: "make_skill_check 1 stealth 18 --advantage",
              description: "Character 1 makes a DC 18 Stealth check with advantage"
    end
  end

  # Tool: Make Ability Check
  command "make_ability_check" do
    description "Perform raw ability check (Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma)"

    argument :character_id, required: true, type: :integer
    argument :ability, required: true, type: :string
    argument :dc, required: true, type: :integer

    option :advantage, type: :boolean, default: false
    option :disadvantage, type: :boolean, default: false

    validates do
      presence :character_id, :ability, :dc
      enum :ability, %w[strength dexterity constitution intelligence wisdom charisma]
      range :dc, 1..30
    end

    execute <<-'RUBY'
      character = Character.find(params[:character_id])
      ability_name = params[:ability]
      dc = params[:dc]

      modifier = character.send("#{ability_name}_modifier")

      # Roll d20 with advantage/disadvantage
      if params[:advantage] && params[:disadvantage]
        roll = DiceRoller.roll('1d20')
      elsif params[:advantage]
        roll = [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].max
      elsif params[:disadvantage]
        roll = [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].min
      else
        roll = DiceRoller.roll('1d20')
      end

      total = roll + modifier
      success = total >= dc

      {
        success: success,
        roll: roll,
        modifier: modifier,
        total: total,
        dc: dc,
        ability: ability_name,
        natural_20: roll == 20,
        natural_1: roll == 1
      }
    RUBY
  end

  # Tool: Make Saving Throw
  command "make_saving_throw" do
    description "Perform D&D 5e saving throw (resist spells, traps, environmental hazards)"

    argument :character_id, required: true, type: :integer
    argument :save_type, required: true, type: :string, description: "STR, DEX, CON, INT, WIS, or CHA"
    argument :dc, required: true, type: :integer

    option :advantage, type: :boolean, default: false
    option :disadvantage, type: :boolean, default: false
    option :source, type: :string, default: nil, description: "What caused the save (spell, trap, etc.)"

    validates do
      presence :character_id, :save_type, :dc
      enum :save_type, %w[strength dexterity constitution intelligence wisdom charisma STR DEX CON INT WIS CHA]
      range :dc, 1..30
    end

    execute <<-'RUBY'
      character = Character.find(params[:character_id])

      # Normalize save type
      save_map = {
        'STR' => 'strength', 'DEX' => 'dexterity', 'CON' => 'constitution',
        'INT' => 'intelligence', 'WIS' => 'wisdom', 'CHA' => 'charisma'
      }
      ability_name = save_map[params[:save_type].upcase] || params[:save_type].downcase

      # Get save modifier
      ability_modifier = character.send("#{ability_name}_modifier")
      proficiency_bonus = ((character.level - 1) / 4) + 2

      # Check if proficient in this save (class determines this)
      proficient_saves = [] # Would come from character.character_class.proficient_saves
      is_proficient = proficient_saves.include?(ability_name)

      total_modifier = ability_modifier + (is_proficient ? proficiency_bonus : 0)

      # Roll d20
      if params[:advantage] && params[:disadvantage]
        roll = DiceRoller.roll('1d20')
      elsif params[:advantage]
        roll = [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].max
      elsif params[:disadvantage]
        roll = [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].min
      else
        roll = DiceRoller.roll('1d20')
      end

      total = roll + total_modifier
      success = total >= params[:dc]

      {
        success: success,
        roll: roll,
        modifier: total_modifier,
        total: total,
        dc: params[:dc],
        save_type: ability_name,
        source: params[:source],
        proficient: is_proficient,
        natural_20: roll == 20,
        natural_1: roll == 1
      }
    RUBY
  end

  # Tool: Make Attack Roll
  command "make_attack" do
    description "Make attack roll and damage roll for D&D 5e combat"

    argument :attacker_id, required: true, type: :integer
    argument :target_id, required: true, type: :integer
    argument :attack_type, required: true, type: :string

    option :weapon_name, type: :string, default: "Unarmed Strike"
    option :damage_dice, type: :string, default: "1d4"
    option :damage_type, type: :string, default: "bludgeoning"
    option :advantage, type: :boolean, default: false
    option :disadvantage, type: :boolean, default: false

    validates do
      presence :attacker_id, :target_id, :attack_type
      enum :attack_type, %w[melee ranged spell]
      enum :damage_type, %w[
        bludgeoning piercing slashing acid cold fire force lightning
        necrotic poison psychic radiant thunder
      ]
    end

    execute <<-'RUBY'
      attacker = Character.find(params[:attacker_id])
      target = Character.find(params[:target_id])

      # Determine attack modifier
      attack_modifier = case params[:attack_type]
                        when 'melee' then attacker.strength_modifier
                        when 'ranged' then attacker.dexterity_modifier
                        when 'spell' then attacker.intelligence_modifier # Simplified
                        end

      proficiency_bonus = ((attacker.level - 1) / 4) + 2
      attack_bonus = attack_modifier + proficiency_bonus

      # Roll attack (d20)
      if params[:advantage] && params[:disadvantage]
        attack_roll = DiceRoller.roll('1d20')
      elsif params[:advantage]
        attack_roll = [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].max
      elsif params[:disadvantage]
        attack_roll = [DiceRoller.roll('1d20'), DiceRoller.roll('1d20')].min
      else
        attack_roll = DiceRoller.roll('1d20')
      end

      attack_total = attack_roll + attack_bonus
      target_ac = target.calculated_armor_class

      hit = attack_total >= target_ac
      critical = attack_roll == 20
      critical_miss = attack_roll == 1

      damage = 0
      damage_rolls = []

      if hit || critical
        # Roll damage
        if critical
          # Critical hit - double damage dice
          damage_rolls << DiceRoller.roll(params[:damage_dice])
          damage_rolls << DiceRoller.roll(params[:damage_dice])
          damage = damage_rolls.sum + attack_modifier
        else
          damage_roll = DiceRoller.roll(params[:damage_dice])
          damage_rolls << damage_roll
          damage = damage_roll + attack_modifier
        end

        damage = [damage, 1].max # Minimum 1 damage on hit
      end

      {
        hit: hit,
        critical: critical,
        critical_miss: critical_miss,
        attack_roll: attack_roll,
        attack_bonus: attack_bonus,
        attack_total: attack_total,
        target_ac: target_ac,
        damage: damage,
        damage_rolls: damage_rolls,
        damage_type: params[:damage_type],
        weapon: params[:weapon_name]
      }
    RUBY
  end

  # Tool: Cast Spell (Simplified)
  command "cast_spell" do
    description "Cast a D&D 5e spell with spell attack or saving throw"

    argument :caster_id, required: true, type: :integer
    argument :spell_name, required: true, type: :string
    argument :target_ids, required: true, type: :array

    option :spell_level, type: :integer, default: 1
    option :spell_save_dc, type: :integer, default: nil
    option :upcasted, type: :boolean, default: false

    validates do
      presence :caster_id, :spell_name, :target_ids
      range :spell_level, 0..9
    end

    execute <<-'RUBY'
      caster = Character.find(params[:caster_id])
      targets = Character.where(id: params[:target_ids])

      # Calculate spell save DC if not provided
      spell_save_dc = params[:spell_save_dc] || (8 + caster.intelligence_modifier + ((caster.level - 1) / 4 + 2))

      # Simplified spell system - would look up from Spell model in real system
      results = targets.map do |target|
        {
          target_id: target.id,
          target_name: target.name,
          spell_save_dc: spell_save_dc,
          # Would execute spell-specific effects here
          effect: "#{params[:spell_name]} cast on #{target.name}"
        }
      end

      {
        caster_id: caster.id,
        caster_name: caster.name,
        spell_name: params[:spell_name],
        spell_level: params[:spell_level],
        spell_save_dc: spell_save_dc,
        targets_affected: results.size,
        results: results
      }
    RUBY
  end
end
