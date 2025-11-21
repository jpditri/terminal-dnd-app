# frozen_string_literal: true

# Combat tracking for D&D 5e characters
# Manages action economy, conditions, death saves, and combat resources
# Ported from heretical-web-app with adaptations for terminal-dnd
class CharacterCombatTracker < ApplicationRecord
  belongs_to :character

  # Validations
  validates :character_id, presence: true, uniqueness: true
  validates :exhaustion_level,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :temp_hp, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Callbacks
  after_initialize :initialize_defaults, if: :new_record?

  # ========================================
  # INITIATIVE
  # ========================================

  # Roll initiative: d20 + DEX modifier
  def roll_initiative
    dex_mod = character.dexterity_modifier
    roll = rand(1..20)
    total = roll + dex_mod

    update(initiative_roll: total)
    log_action('initiative', { roll: roll, modifier: dex_mod, total: total })

    { roll: roll, modifier: dex_mod, total: total, natural: roll }
  end

  # Roll initiative with advantage
  def roll_initiative_advantage
    dex_mod = character.dexterity_modifier
    roll1 = rand(1..20)
    roll2 = rand(1..20)
    roll = [roll1, roll2].max
    total = roll + dex_mod

    update(initiative_roll: total)
    log_action('initiative', { roll: roll, rolls: [roll1, roll2], advantage: true, modifier: dex_mod, total: total })

    { roll: roll, rolls: [roll1, roll2], modifier: dex_mod, total: total, natural: roll }
  end

  # Roll initiative with disadvantage
  def roll_initiative_disadvantage
    dex_mod = character.dexterity_modifier
    roll1 = rand(1..20)
    roll2 = rand(1..20)
    roll = [roll1, roll2].min
    total = roll + dex_mod

    update(initiative_roll: total)
    log_action('initiative', { roll: roll, rolls: [roll1, roll2], disadvantage: true, modifier: dex_mod, total: total })

    { roll: roll, rolls: [roll1, roll2], modifier: dex_mod, total: total, natural: roll }
  end

  # ========================================
  # ACTION ECONOMY
  # ========================================

  # Reset action economy for new turn
  def start_turn
    resources = action_resources || {}
    resources['current_turn_actions'] = {
      'action_used' => false,
      'bonus_action_used' => false,
      'reaction_used' => false,
      'leveled_spell_cast' => false,
      'bonus_action_spell_cast' => false,
      'dashed' => false
    }
    resources['current_turn_movement'] = 0

    # Mark JSONB as changed
    self.action_resources_will_change!
    self.action_resources = resources
    save!

    log_action('turn_start', { character: character.name })
  end

  # Use action
  def use_action
    return false if action_used?

    resources = action_resources || {}
    current_turn_actions = resources['current_turn_actions'] || {}
    current_turn_actions['action_used'] = true
    resources['current_turn_actions'] = current_turn_actions

    action_resources_will_change!
    update(action_resources: resources)
    log_action('action_used', {})
    true
  end

  # Use bonus action
  def use_bonus_action
    return false unless has_bonus_action?

    resources = action_resources || {}
    current_turn_actions = resources['current_turn_actions'] || {}
    current_turn_actions['bonus_action_used'] = true
    resources['current_turn_actions'] = current_turn_actions

    action_resources_will_change!
    update(action_resources: resources)
    log_action('bonus_action_used', {})
    true
  end

  # Use reaction
  def use_reaction
    return false unless has_reaction?

    resources = action_resources || {}
    current_turn_actions = resources['current_turn_actions'] || {}
    current_turn_actions['reaction_used'] = true
    resources['current_turn_actions'] = current_turn_actions

    action_resources_will_change!
    update(action_resources: resources)
    log_action('reaction_used', {})
    true
  end

  # Use movement
  def use_movement(feet)
    resources = action_resources || {}
    movement_used = resources['current_turn_movement'] || 0
    max_movement = character.speed || 30

    return false if movement_used + feet > max_movement

    resources['current_turn_movement'] = movement_used + feet
    action_resources_will_change!
    update(action_resources: resources)
    log_action('movement_used', { feet: feet, remaining: max_movement - resources['current_turn_movement'] })
    true
  end

  # Check if action is available
  def action_available?
    !action_used?
  end

  # Check if action is used
  def action_used?
    resources = action_resources || {}
    current_turn_actions = resources['current_turn_actions'] || {}
    current_turn_actions['action_used'] == true
  end

  # Check if bonus action is available
  def has_bonus_action?
    resources = action_resources || {}
    current_turn_actions = resources['current_turn_actions'] || {}
    !current_turn_actions['bonus_action_used']
  end

  # Check if reaction is available
  def has_reaction?
    resources = action_resources || {}
    current_turn_actions = resources['current_turn_actions'] || {}
    !current_turn_actions['reaction_used']
  end

  # Get remaining movement
  def remaining_movement
    movement_used = (action_resources || {})['current_turn_movement'] || 0
    (character.speed || 30) - movement_used
  end

  # ========================================
  # DEATH SAVES
  # ========================================

  # Roll a death save
  def roll_death_save(advantage: false, disadvantage: false)
    # Check if character is eligible for death saves
    return { error: 'Character has positive HP' } if character.hit_points_current > 0
    return { error: 'Character is already stable' } if stable?

    # Check if character is already dead
    current_saves = death_saves || { 'successes' => 0, 'failures' => 0 }
    return { error: 'Character is dead', result: :already_dead } if current_saves['failures'] >= 3

    # Check for Periapt of Wound Closure or other sources of advantage
    resources = action_resources || {}
    has_periapt = resources['periapt_of_wound_closure'] == true

    # Periapt grants advantage on death saves
    advantage = true if has_periapt
    auto_stabilize_threshold = 3

    # Roll with advantage/disadvantage
    roll, rolls = if advantage && disadvantage
                    # They cancel out
                    r = rand(1..20)
                    [r, [r]]
                  elsif advantage
                    r1 = rand(1..20)
                    r2 = rand(1..20)
                    [[r1, r2].max, [r1, r2]]
                  elsif disadvantage
                    r1 = rand(1..20)
                    r2 = rand(1..20)
                    [[r1, r2].min, [r1, r2]]
                  else
                    r = rand(1..20)
                    [r, [r]]
                  end

    saves = current_saves.deep_dup

    result = case roll
             when 20
               # Natural 20 - regain 1 HP and become conscious, reset ALL death saves
               character.update(hit_points_current: 1)
               # Completely reset death saves - both successes AND failures
               reset_death_saves
               log_action('death_save',
                          { roll: roll, rolls: rolls, result: 'natural_20', hp_restored: 1, advantage: advantage,
                            disadvantage: disadvantage })
               { roll: roll, rolls: rolls, result: :natural_20, conscious: true, hp: 1, successes: 0, failures: 0,
                 advantage: advantage, disadvantage: disadvantage }
             when 10..19
               # Success
               saves['successes'] += 1
               if saves['successes'] >= auto_stabilize_threshold
                 self.death_saves_will_change!
                 update(death_saves: saves)
                 stabilize
                 log_action('death_save',
                            { roll: roll, rolls: rolls, result: 'stabilized', advantage: advantage,
                              disadvantage: disadvantage })
                 { roll: roll, rolls: rolls, result: :stabilized, successes: saves['successes'],
                   failures: saves['failures'], advantage: advantage, disadvantage: disadvantage }
               else
                 self.death_saves_will_change!
                 update(death_saves: saves)
                 log_action('death_save',
                            { roll: roll, rolls: rolls, result: 'success', successes: saves['successes'],
                              advantage: advantage, disadvantage: disadvantage })
                 { roll: roll, rolls: rolls, result: :success, successes: saves['successes'],
                   failures: saves['failures'], advantage: advantage, disadvantage: disadvantage }
               end
             when 2..9
               # Failure
               saves['failures'] += 1
               self.death_saves_will_change!
               update(death_saves: saves)
               if saves['failures'] >= 3
                 log_action('death_save',
                            { roll: roll, rolls: rolls, result: 'death', advantage: advantage,
                              disadvantage: disadvantage })
                 { roll: roll, rolls: rolls, result: :death, successes: saves['successes'],
                   failures: saves['failures'], advantage: advantage, disadvantage: disadvantage }
               else
                 log_action('death_save',
                            { roll: roll, rolls: rolls, result: 'failure', failures: saves['failures'],
                              advantage: advantage, disadvantage: disadvantage })
                 { roll: roll, rolls: rolls, result: :failure, successes: saves['successes'],
                   failures: saves['failures'], advantage: advantage, disadvantage: disadvantage }
               end
             when 1
               # Natural 1 - counts as 2 failures
               saves['failures'] += 2
               self.death_saves_will_change!
               update(death_saves: saves)
               if saves['failures'] >= 3
                 log_action('death_save',
                            { roll: roll, rolls: rolls, result: 'death', advantage: advantage,
                              disadvantage: disadvantage })
                 { roll: roll, rolls: rolls, result: :death, successes: saves['successes'],
                   failures: saves['failures'], advantage: advantage, disadvantage: disadvantage }
               else
                 log_action('death_save',
                            { roll: roll, rolls: rolls, result: 'critical_failure', failures: saves['failures'],
                              advantage: advantage, disadvantage: disadvantage })
                 { roll: roll, rolls: rolls, result: :critical_failure, successes: saves['successes'],
                   failures: saves['failures'], advantage: advantage, disadvantage: disadvantage }
               end
             end

    result
  end

  # Stabilize character (3 successes on death saves)
  def stabilize
    self.death_saves_will_change!
    update(death_saves: { 'successes' => 0, 'failures' => 0 })
    log_action('stabilized', {})
  end

  # Reset death saves (when HP restored)
  def reset_death_saves
    self.death_saves_will_change!
    update(death_saves: { 'successes' => 0, 'failures' => 0 })
    log_action('death_saves_reset', { reason: 'HP restored' })
  end

  # Auto-reset death saves when healed above 0 HP
  def auto_reset_death_saves_if_healed
    current_saves = death_saves || {}
    if character.hit_points_current > 0 && (current_saves['successes'].to_i > 0 || current_saves['failures'].to_i > 0)
      reset_death_saves
    end
  end

  # Check if character is stable at 0 HP
  def stable?
    current_saves = death_saves || {}
    character.hit_points_current == 0 && (current_saves['successes'] || 0) >= 3
  end

  # Check if character is dying
  def dying?
    character.hit_points_current <= 0 && !stable?
  end

  # ========================================
  # CONDITIONS
  # ========================================

  # Apply a condition
  def apply_condition(name, duration: nil, source: nil)
    resources = action_resources || {}
    conds = resources['conditions'] || []

    # Check if condition already exists
    existing = conds.find { |c| c['name'] == name }
    return false if existing

    condition = {
      'name' => name,
      'duration' => duration,
      'source' => source,
      'applied_at' => Time.current.to_i
    }

    conds << condition
    resources['conditions'] = conds
    action_resources_will_change!
    update(action_resources: resources)
    log_action('condition_applied', { condition: name, duration: duration, source: source })
    true
  end

  # Remove a condition
  def remove_condition(name)
    resources = action_resources || {}
    conds = resources['conditions'] || []
    conds.reject! { |c| c['name'] == name }
    resources['conditions'] = conds
    action_resources_will_change!
    update(action_resources: resources)
    log_action('condition_removed', { condition: name })
  end

  # Check if character has a condition
  def has_condition?(name)
    resources = action_resources || {}
    conds = resources['conditions'] || []
    conds.any? { |c| c['name'] == name }
  end

  # Decrease condition durations (call at start/end of round)
  def tick_conditions
    resources = action_resources || {}
    conds = resources['conditions'] || []
    conds.each do |condition|
      next unless condition['duration'].is_a?(Integer)

      condition['duration'] -= 1
      log_action('condition_expired', { condition: condition['name'] }) if condition['duration'] <= 0
    end

    # Remove expired conditions
    conds.reject! { |c| c['duration'].is_a?(Integer) && c['duration'] <= 0 }
    resources['conditions'] = conds
    action_resources_will_change!
    update(action_resources: resources)
  end

  # Get active conditions
  def active_conditions
    resources = action_resources || {}
    resources['conditions'] || []
  end

  # Get character conditions (for compatibility)
  def conditions
    active_conditions
  end

  # ========================================
  # RESOURCES
  # ========================================

  # Set a resource (e.g., ki points, superiority dice)
  def set_resource(name, max:, current: nil)
    resources = action_resources || {}
    resources[name] = {
      'max' => max,
      'current' => current || max
    }
    action_resources_will_change!
    update(action_resources: resources)
  end

  # Use a resource
  def use_resource(name, amount = 1)
    resources = action_resources || {}
    resource = resources[name]

    return false unless resource
    return false if resource['current'] < amount

    resource['current'] -= amount
    action_resources_will_change!
    update(action_resources: resources)
    log_action('resource_used', { resource: name, amount: amount, remaining: resource['current'] })
    true
  end

  # Restore a resource
  def restore_resource(name, amount = 1)
    resources = action_resources || {}
    resource = resources[name]

    return false unless resource

    resource['current'] = [resource['current'] + amount, resource['max']].min
    action_resources_will_change!
    update(action_resources: resources)
    log_action('resource_restored', { resource: name, amount: amount, current: resource['current'] })
    true
  end

  # Get resource current/max
  def get_resource(name)
    (action_resources || {})[name]
  end

  # Short rest recovery
  def short_rest
    resources = action_resources || {}

    # Restore resources that recover on short rest
    resources.each do |name, resource|
      next unless resource.is_a?(Hash)

      resource['current'] = resource['max'] if resource['recovery'] == 'short_rest'
    end

    # Reset action economy
    resources['current_turn_actions'] = {
      'action_used' => false,
      'bonus_action_used' => false,
      'reaction_used' => false,
      'leveled_spell_cast' => false,
      'bonus_action_spell_cast' => false,
      'dashed' => false
    }

    action_resources_will_change!
    update(action_resources: resources)
    log_action('short_rest', {})
  end

  # Long rest recovery
  def long_rest
    resources = action_resources || {}

    # Restore all resources
    resources.each do |name, resource|
      next unless resource.is_a?(Hash)

      resource['current'] = resource['max']
    end

    # Remove only conditions with long_rest duration, keep permanent ones
    conds = resources['conditions'] || []
    conds.reject! { |condition| condition['duration'] == 'long_rest' }
    resources['conditions'] = conds

    # Reset action economy
    resources['current_turn_actions'] = {
      'action_used' => false,
      'bonus_action_used' => false,
      'reaction_used' => false,
      'leveled_spell_cast' => false,
      'bonus_action_spell_cast' => false,
      'dashed' => false
    }

    # Reset spell slots used
    resources['spell_slots_used'] = {}

    action_resources_will_change!
    death_saves_will_change!

    update(
      action_resources: resources,
      death_saves: { 'successes' => 0, 'failures' => 0 },
      temp_hp: 0,
      exhaustion_level: [exhaustion_level - 1, 0].max
    )

    log_action('long_rest', {})
  end

  # ========================================
  # COMBAT LOG
  # ========================================

  # Log an action
  def log_action(action_type, details = {})
    resources = action_resources || {}
    log = resources['combat_log'] || []

    entry = {
      'timestamp' => Time.current.to_i,
      'action' => action_type,
      'details' => details,
      'round' => current_round
    }

    log << entry

    # Keep only last 100 entries to prevent bloat
    log = log.last(100)

    resources['combat_log'] = log
    action_resources_will_change!
    update(action_resources: resources)
  end

  # Get combat log
  def get_combat_log(limit: 20)
    resources = action_resources || {}
    log = resources['combat_log'] || []
    log.last(limit).reverse
  end

  # Clear combat log
  def clear_combat_log
    resources = action_resources || {}
    resources['combat_log'] = []
    action_resources_will_change!
    update(action_resources: resources)
  end

  # Get current round from log
  def current_round
    resources = action_resources || {}
    resources['current_round'] || 1
  end

  # Advance to next round
  def advance_round
    resources = action_resources || {}
    resources['current_round'] = current_round + 1
    action_resources_will_change!
    update(action_resources: resources)
    tick_conditions
    log_action('new_round', { round: resources['current_round'] })
  end

  # ========================================
  # COMBAT STATE
  # ========================================

  # Start combat
  def start_combat
    reset_for_combat
    log_action('combat_start', { character: character.name })
  end

  # End combat
  def end_combat
    log_action('combat_end', { character: character.name })
    reset_for_combat
  end

  # Reset for new combat
  def reset_for_combat
    action_resources_will_change!
    update(
      initiative_roll: nil,
      action_resources: {
        'current_turn_movement' => 0,
        'current_turn_actions' => {
          'action_used' => false,
          'bonus_action_used' => false,
          'reaction_used' => false,
          'leveled_spell_cast' => false,
          'bonus_action_spell_cast' => false,
          'dashed' => false
        },
        'current_round' => 1
      }
    )
  end

  private

  # Initialize default values
  def initialize_defaults
    self.action_resources ||= {}
    self.death_saves ||= { 'successes' => 0, 'failures' => 0 }
    self.temp_hp ||= 0
    self.exhaustion_level ||= 0
    initialize_class_resources
  end

  # Initialize class-specific resources
  def initialize_class_resources
    return unless character&.character_class

    class_name = character.character_class.name&.downcase
    level = character.level || 1

    case class_name
    when 'fighter'
      initialize_fighter_resources(level)
    when 'monk'
      initialize_monk_resources(level)
    when 'warlock'
      initialize_warlock_resources(level)
    end
  end

  # Initialize Fighter resources
  def initialize_fighter_resources(level)
    resources = action_resources || {}

    # Action Surge - 1 use at level 2, 2 uses at level 17
    if level >= 2
      uses = level >= 17 ? 2 : 1
      resources['action_surge'] ||= { 'max' => uses, 'current' => uses, 'recovery' => 'short_rest' }
    end

    # Second Wind - 1 use, recovers on short rest
    if level >= 1
      resources['second_wind'] ||= { 'max' => 1, 'current' => 1, 'recovery' => 'short_rest' }
    end

    # Superiority Dice - for Battle Master subclass
    if level >= 3
      dice_count = case level
                   when 3..6 then 4
                   when 7..14 then 5
                   else 6
                   end
      resources['superiority'] ||= { 'max' => dice_count, 'current' => dice_count, 'recovery' => 'short_rest' }
    end

    self.action_resources = resources
  end

  # Initialize Monk resources
  def initialize_monk_resources(level)
    resources = action_resources || {}

    # Ki Points
    resources['ki_points'] ||= { 'max' => level, 'current' => level, 'recovery' => 'short_rest' } if level >= 2

    self.action_resources = resources
  end

  # Initialize Warlock resources
  def initialize_warlock_resources(level)
    resources = action_resources || {}

    # Spell Slots (simplified - actual warlock slots are more complex)
    if level >= 1
      slot_level = case level
                   when 1..2 then 1
                   when 3..4 then 2
                   when 5..6 then 3
                   when 7..8 then 4
                   else 5
                   end

      slot_count = case level
                   when 1 then 1
                   when 2..10 then 2
                   when 11..16 then 3
                   else 4
                   end

      resources['spell_slots'] ||= { 'max' => slot_count, 'current' => slot_count, 'level' => slot_level,
                                     'recovery' => 'short_rest' }
    end

    self.action_resources = resources
  end

  # Get resistances (for compatibility)
  def resistances
    resources = action_resources || {}
    resources['resistances'] || []
  end

  # Get immunities (for compatibility)
  def immunities
    resources = action_resources || {}
    resources['immunities'] || []
  end

  # Get vulnerabilities (for compatibility)
  def vulnerabilities
    resources = action_resources || {}
    resources['vulnerabilities'] || []
  end
end
