# frozen_string_literal: true

module Homebrew
  # Builds structured property definitions for magic items
  # Provides helpers for common D&D 5e item properties
  class ItemPropertyBuilder
    attr_reader :properties

    def initialize
      @properties = {}
    end

    # Build properties from hash
    # @param property_hash [Hash] Hash of properties
    # @return [Hash] Normalized properties
    def self.build_from_hash(property_hash)
      builder = new
      property_hash.each do |key, value|
        builder.send("add_#{key}", value) if builder.respond_to?("add_#{key}", true)
      end
      builder.properties
    end

    # Common property builders

    # Add attack bonus (for weapons)
    def add_attack_bonus(bonus)
      @properties[:attack_bonus] = bonus.to_i
      self
    end

    # Add damage bonus (for weapons)
    def add_damage_bonus(bonus)
      @properties[:damage_bonus] = bonus.to_i
      self
    end

    # Add damage dice (for weapons)
    # @param dice [String] Dice expression like "2d6" or "1d8+3"
    def add_damage_dice(dice)
      # Validate dice expression
      Treasure::DiceParser.roll(dice) # Will raise if invalid
      @properties[:damage_dice] = dice
      self
    rescue Treasure::DiceParser::InvalidDiceExpression => e
      raise ArgumentError, "Invalid damage dice: #{e.message}"
    end

    # Add damage type
    def add_damage_type(damage_type)
      valid_types = %w[acid bludgeoning cold fire force lightning necrotic piercing poison psychic radiant slashing thunder]
      unless valid_types.include?(damage_type.to_s.downcase)
        raise ArgumentError, "Invalid damage type: #{damage_type}"
      end

      @properties[:damage_type] = damage_type.to_s.downcase
      self
    end

    # Add AC bonus (for armor/shields)
    def add_ac_bonus(bonus)
      @properties[:ac_bonus] = bonus.to_i
      self
    end

    # Add ability score bonus
    # @param ability [String] Ability score name (strength, dexterity, etc.)
    # @param bonus [Integer] Bonus amount
    def add_ability_bonus(ability, bonus)
      valid_abilities = %w[strength dexterity constitution intelligence wisdom charisma]
      unless valid_abilities.include?(ability.to_s.downcase)
        raise ArgumentError, "Invalid ability: #{ability}"
      end

      @properties[:ability_bonuses] ||= {}
      @properties[:ability_bonuses][ability.to_s.downcase.to_sym] = bonus.to_i
      self
    end

    # Add saving throw bonus
    # @param ability [String] Ability for saving throw
    # @param bonus [Integer] Bonus amount
    def add_saving_throw_bonus(ability, bonus)
      valid_abilities = %w[strength dexterity constitution intelligence wisdom charisma]
      unless valid_abilities.include?(ability.to_s.downcase)
        raise ArgumentError, "Invalid ability: #{ability}"
      end

      @properties[:saving_throw_bonuses] ||= {}
      @properties[:saving_throw_bonuses][ability.to_s.downcase.to_sym] = bonus.to_i
      self
    end

    # Add spell effect
    # @param spell_name [String] Name of the spell
    # @param level [Integer] Spell level
    # @param uses [Integer] Number of daily uses (optional)
    # @param recharge [String] Recharge condition (optional, e.g., "dawn", "short rest")
    def add_spell_effect(spell_name:, level:, uses: nil, recharge: nil)
      @properties[:spell_effects] ||= []
      @properties[:spell_effects] << {
        spell_name: spell_name,
        level: level.to_i,
        uses: uses&.to_i,
        recharge: recharge
      }.compact
      self
    end

    # Add daily use limitation
    def add_daily_uses(uses, recharge: 'dawn')
      @properties[:daily_uses] = uses.to_i
      @properties[:recharge_condition] = recharge
      self
    end

    # Add special ability
    # @param name [String] Name of the ability
    # @param description [String] What the ability does
    # @param uses [Integer] Number of uses (optional)
    def add_special_ability(name:, description:, uses: nil)
      @properties[:special_abilities] ||= []
      @properties[:special_abilities] << {
        name: name,
        description: description,
        uses: uses&.to_i
      }.compact
      self
    end

    # Add resistance to damage type
    def add_damage_resistance(damage_type)
      valid_types = %w[acid bludgeoning cold fire force lightning necrotic piercing poison psychic radiant slashing thunder]
      unless valid_types.include?(damage_type.to_s.downcase)
        raise ArgumentError, "Invalid damage type: #{damage_type}"
      end

      @properties[:damage_resistances] ||= []
      @properties[:damage_resistances] << damage_type.to_s.downcase
      @properties[:damage_resistances].uniq!
      self
    end

    # Add immunity to damage type
    def add_damage_immunity(damage_type)
      valid_types = %w[acid bludgeoning cold fire force lightning necrotic piercing poison psychic radiant slashing thunder]
      unless valid_types.include?(damage_type.to_s.downcase)
        raise ArgumentError, "Invalid damage type: #{damage_type}"
      end

      @properties[:damage_immunities] ||= []
      @properties[:damage_immunities] << damage_type.to_s.downcase
      @properties[:damage_immunities].uniq!
      self
    end

    # Add condition immunity
    def add_condition_immunity(condition)
      valid_conditions = %w[blinded charmed deafened exhaustion frightened grappled incapacitated invisible paralyzed petrified poisoned prone restrained stunned unconscious]
      unless valid_conditions.include?(condition.to_s.downcase)
        raise ArgumentError, "Invalid condition: #{condition}"
      end

      @properties[:condition_immunities] ||= []
      @properties[:condition_immunities] << condition.to_s.downcase
      @properties[:condition_immunities].uniq!
      self
    end

    # Add speed modification
    def add_speed_bonus(speed_type, bonus)
      valid_types = %w[walk swim fly climb burrow]
      unless valid_types.include?(speed_type.to_s.downcase)
        raise ArgumentError, "Invalid speed type: #{speed_type}"
      end

      @properties[:speed_bonuses] ||= {}
      @properties[:speed_bonuses][speed_type.to_s.downcase.to_sym] = bonus.to_i
      self
    end

    # Add weapon property
    def add_weapon_property(property)
      valid_properties = %w[finesse heavy light loading reach thrown versatile ammunition]
      unless valid_properties.include?(property.to_s.downcase)
        raise ArgumentError, "Invalid weapon property: #{property}"
      end

      @properties[:weapon_properties] ||= []
      @properties[:weapon_properties] << property.to_s.downcase
      @properties[:weapon_properties].uniq!
      self
    end

    # Add armor property
    def add_armor_property(property)
      valid_properties = %w[stealth_disadvantage]
      unless valid_properties.include?(property.to_s.downcase)
        raise ArgumentError, "Invalid armor property: #{property}"
      end

      @properties[:armor_properties] ||= []
      @properties[:armor_properties] << property.to_s.downcase
      @properties[:armor_properties].uniq!
      self
    end

    # Add skill bonus
    def add_skill_bonus(skill, bonus)
      valid_skills = %w[
        acrobatics animal_handling arcana athletics deception history insight intimidation
        investigation medicine nature perception performance persuasion religion sleight_of_hand
        stealth survival
      ]
      unless valid_skills.include?(skill.to_s.downcase)
        raise ArgumentError, "Invalid skill: #{skill}"
      end

      @properties[:skill_bonuses] ||= {}
      @properties[:skill_bonuses][skill.to_s.downcase.to_sym] = bonus.to_i
      self
    end

    # Add charges system
    # @param max_charges [Integer] Maximum charges
    # @param recharge [String] How charges recharge (e.g., "1d6+4 at dawn")
    def add_charges(max_charges, recharge:)
      @properties[:charges] = {
        max: max_charges.to_i,
        recharge: recharge
      }
      self
    end

    # Add sentient item properties
    def make_sentient(alignment:, intelligence:, wisdom:, charisma:, languages: [], purpose: nil)
      @properties[:sentient] = {
        alignment: alignment,
        intelligence: intelligence.to_i,
        wisdom: wisdom.to_i,
        charisma: charisma.to_i,
        languages: languages,
        purpose: purpose
      }.compact
      self
    end

    # Add curse
    def add_curse(description:, removal_condition: nil)
      @properties[:cursed] = true
      @properties[:curse_description] = description
      @properties[:curse_removal] = removal_condition if removal_condition
      self
    end

    # Preset builders for common magic items

    # Build a +X weapon
    def self.magic_weapon(bonus:, damage_dice: nil, damage_type: nil)
      builder = new
      builder.add_attack_bonus(bonus)
      builder.add_damage_bonus(bonus)
      builder.add_damage_dice(damage_dice) if damage_dice
      builder.add_damage_type(damage_type) if damage_type
      builder.properties
    end

    # Build a +X armor
    def self.magic_armor(ac_bonus:)
      builder = new
      builder.add_ac_bonus(ac_bonus)
      builder.properties
    end

    # Build a stat-boosting item (like Belt of Giant Strength)
    def self.ability_score_item(ability:, bonus:)
      builder = new
      builder.add_ability_bonus(ability, bonus)
      builder.properties
    end

    # Build a spell-storing item
    def self.spell_item(spell_name:, level:, uses:, recharge: 'dawn')
      builder = new
      builder.add_spell_effect(spell_name: spell_name, level: level, uses: uses, recharge: recharge)
      builder.properties
    end

    # Build a resistance item
    def self.resistance_item(*damage_types)
      builder = new
      damage_types.each { |type| builder.add_damage_resistance(type) }
      builder.properties
    end

    # Get the built properties
    def build
      @properties
    end
  end
end
