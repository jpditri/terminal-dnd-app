# frozen_string_literal: true

module Multiplayer
  class RulesExplainer

    def explain_ability_check(ability, modifier, proficient: false, expertise: false)
      # TODO: Implement
    end

    def explain_saving_throw(ability, modifier, proficient: false)
      # TODO: Implement
    end

    def explain_attack(weapon, modifier, properties: [])
      # TODO: Implement
    end

    def explain_damage(weapon, damage_dice, modifier, critical: false, properties: [], two_handed: false)
      # TODO: Implement
    end

    def explain_critical_hit(weapon, base_dice, crit_dice, modifier)
      # TODO: Implement
    end

    def explain_advantage_disadvantage(advantage: false, disadvantage: false, dice_results: [])
      # TODO: Implement
    end

    def explain_death_save(result, natural_roll)
      # TODO: Implement
    end

    def explain_sneak_attack(level)
      # TODO: Implement
    end

    def explain_divine_smite(spell_slot_level)
      # TODO: Implement
    end

    def explain_damage_modification(damage_type, raw_damage, final_damage, modification_type)
      # TODO: Implement
    end

    def weapon_property_explanation(property)
      # TODO: Implement
    end

    def damage_type_explanation(damage_type)
      # TODO: Implement
    end

    def condition_explanation(condition)
      # TODO: Implement
    end

    def build_complete_explanation(roll_data)
      # TODO: Implement
    end
  end
end