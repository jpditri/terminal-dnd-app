# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_11_21_151701) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_logs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_session_id", null: false
    t.string "action_type", null: false
    t.text "description"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_effects", force: :cascade do |t|
    t.integer "combatant_id", null: false
    t.string "effect_type", null: false
    t.string "name"
    t.text "description"
    t.integer "value"
    t.integer "duration_rounds"
    t.integer "save_dc"
    t.string "trigger"
    t.jsonb "metadata", default: {}
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_active_effects_on_discarded_at"
  end

  create_table "adventure_templates", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "difficulty", default: "medium"
    t.integer "estimated_duration"
    t.integer "min_level", default: 1
    t.integer "max_level", default: 20
    t.string "category"
    t.string "status", default: "draft"
    t.jsonb "template_data", default: {}
    t.integer "creator_id"
    t.integer "completion_count", default: 0
    t.integer "usage_count", default: 0
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_adventure_templates_on_discarded_at"
  end

  create_table "ai_contexts", force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "solo_session_id"
    t.jsonb "long_term_memory", default: {}, null: false
    t.jsonb "character_traits", default: {}, null: false
    t.jsonb "world_state", default: {}, null: false
    t.jsonb "relationship_web", default: {}, null: false
    t.jsonb "active_quests", default: [], null: false
    t.jsonb "plot_threads", default: [], null: false
    t.jsonb "npcs_met", default: [], null: false
    t.jsonb "locations_visited", default: [], null: false
    t.jsonb "important_items", default: [], null: false
    t.jsonb "major_events", default: [], null: false
    t.jsonb "session_summaries", default: [], null: false
    t.text "context_seed"
    t.datetime "last_context_update"
    t.integer "context_version", default: 1, null: false
    t.integer "estimated_token_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ai_conversations", force: :cascade do |t|
    t.integer "solo_session_id"
    t.integer "character_id"
    t.string "title"
    t.string "status"
    t.string "ai_model"
    t.text "system_prompt"
    t.jsonb "context_data"
    t.integer "message_count"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_ai_conversations_on_discarded_at"
  end

  create_table "ai_dm_assistants", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.boolean "enabled", default: true, null: false
    t.boolean "paused", null: false
    t.string "creativity_level", default: "balanced", null: false
    t.string "tone", default: "heroic", null: false
    t.text "setting_context"
    t.jsonb "suggestion_types", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_ai_dm_assistants_on_discarded_at"
  end

  create_table "ai_dm_contexts", force: :cascade do |t|
    t.integer "ai_dm_assistant_id", null: false
    t.integer "game_session_id", null: false
    t.jsonb "conversation_history", default: [], null: false
    t.jsonb "active_npcs", default: [], null: false
    t.jsonb "recent_events", default: [], null: false
    t.jsonb "unresolved_threads", default: [], null: false
    t.jsonb "campaign_memory", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ai_dm_overrides", force: :cascade do |t|
    t.integer "ai_dm_assistant_id", null: false
    t.integer "ai_dm_suggestion_id", null: false
    t.integer "user_id", null: false
    t.text "original_suggestion", null: false
    t.text "dm_override", null: false
    t.string "override_type", null: false
    t.jsonb "context_when_overridden", default: {}, null: false
    t.jsonb "reasoning", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ai_dm_suggestions", force: :cascade do |t|
    t.integer "ai_dm_assistant_id", null: false
    t.integer "game_session_id"
    t.integer "user_id", null: false
    t.string "suggestion_type", null: false
    t.text "content", null: false
    t.text "edited_content"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_ai_dm_suggestions_on_discarded_at"
  end

  create_table "ai_messages", force: :cascade do |t|
    t.string "role"
    t.text "content"
    t.jsonb "dice_rolls"
    t.jsonb "narrative_tags"
    t.integer "tokens_used"
    t.integer "response_time_ms"
    t.datetime "deleted_at"
    t.integer "ai_conversation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_ai_messages_on_discarded_at"
  end

  create_table "alignments", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "axis_law_chaos"
    t.string "axis_good_evil"
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_alignments_on_discarded_at"
  end

  create_table "backgrounds", force: :cascade do |t|
    t.string "name"
    t.jsonb "skill_proficiencies"
    t.jsonb "tool_proficiencies"
    t.jsonb "languages"
    t.jsonb "starting_equipment"
    t.string "feature_name"
    t.text "feature_description"
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_backgrounds_on_discarded_at"
  end

  create_table "campaign_join_requests", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "user_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_campaign_join_requests_on_discarded_at"
  end

  create_table "campaign_memberships", force: :cascade do |t|
    t.string "role"
    t.boolean "active"
    t.integer "user_id"
    t.integer "campaign_id"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_campaign_memberships_on_discarded_at"
  end

  create_table "campaign_metrics", force: :cascade do |t|
    t.integer "campaign_id"
    t.date "metric_date"
    t.integer "sessions_count"
    t.integer "total_playtime_minutes"
    t.integer "encounters_count"
    t.integer "combats_count"
    t.integer "npcs_met_count"
    t.integer "quests_started"
    t.integer "quests_completed"
    t.integer "locations_visited"
    t.integer "player_deaths"
    t.integer "monsters_defeated"
    t.decimal "treasure_gained_gp"
    t.integer "experience_gained"
    t.jsonb "engagement_scores"
    t.jsonb "pacing_analysis"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_campaign_metrics_on_discarded_at"
  end

  create_table "campaign_notes", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "note_type"
    t.string "visibility"
    t.integer "campaign_id"
    t.integer "user_id"
    t.integer "game_session_id"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_campaign_notes_on_discarded_at"
  end

  create_table "campaign_ratings", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "user_id", null: false
    t.integer "rating", null: false
    t.text "review"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_campaign_ratings_on_discarded_at"
  end

  create_table "campaign_templates", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "category"
    t.jsonb "tags", default: []
    t.jsonb "template_data", default: {}, null: false
    t.string "visibility", default: "public", null: false
    t.integer "min_level", default: 1
    t.integer "max_level", default: 20
    t.integer "use_count", default: 0, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_campaign_templates_on_discarded_at"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "status"
    t.string "visibility", default: "private"
    t.integer "dm_id"
    t.string "theme"
    t.string "world_time"
    t.string "current_location"
    t.jsonb "settings"
    t.jsonb "house_rules"
    t.integer "max_players"
    t.string "timezone"
    t.string "session_frequency"
    t.boolean "ai_assistant_enabled"
    t.datetime "deleted_at"
    t.integer "world_id"
    t.integer "min_level", default: 1
    t.integer "max_level", default: 20
    t.string "category"
    t.jsonb "tags", default: []
    t.datetime "discarded_at"
    t.integer "template_id"
    t.boolean "looking_for_players"
    t.integer "player_capacity"
    t.string "play_style"
    t.datetime "next_session_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "world_state", default: {}
    t.index ["discarded_at"], name: "index_campaigns_on_discarded_at"
  end

  create_table "character_ai_assistants", force: :cascade do |t|
    t.integer "character_id", null: false
    t.jsonb "conversation_history", default: []
    t.jsonb "generated_content", default: {}
    t.jsonb "tactical_suggestions", default: []
    t.jsonb "roleplay_prompts", default: []
    t.jsonb "personality_analysis", default: {}
    t.string "preferred_ai_model"
    t.integer "ai_usage_tokens", default: 0
    t.boolean "ai_enabled", default: true
    t.jsonb "custom_instructions", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "character_classes", force: :cascade do |t|
    t.string "name"
    t.string "hit_die"
    t.string "primary_ability"
    t.jsonb "saving_throw_proficiencies"
    t.jsonb "skill_proficiencies"
    t.jsonb "armor_proficiencies"
    t.jsonb "weapon_proficiencies"
    t.jsonb "starting_equipment"
    t.jsonb "class_features"
    t.string "spellcasting_ability"
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_character_classes_on_discarded_at"
  end

  create_table "character_combat_trackers", force: :cascade do |t|
    t.integer "character_id", null: false
    t.jsonb "action_resources", default: {}
    t.jsonb "death_saves"
    t.jsonb "conditions", default: []
    t.jsonb "resistances", default: []
    t.jsonb "immunities", default: []
    t.jsonb "vulnerabilities", default: []
    t.integer "temp_hp", default: 0
    t.integer "exhaustion_level", default: 0
    t.integer "initiative_roll"
    t.boolean "has_reaction", default: true
    t.boolean "has_bonus_action", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_resources"], name: "index_character_combat_trackers_on_action_resources", using: :gin, comment: "Fast action economy and attunement lookups"
  end

  create_table "character_feats", force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "feat_id", null: false
    t.integer "level_gained"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "character_inventories", force: :cascade do |t|
    t.integer "character_id", null: false
    t.jsonb "equipped_items", default: {}
    t.jsonb "inventory_grid", default: []
    t.integer "carry_capacity", default: 150
    t.integer "current_weight", default: 0
    t.jsonb "equipment_sets", default: {}
    t.string "active_set"
    t.jsonb "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["currency"], name: "index_character_inventories_on_currency", using: :gin, comment: "Fast currency queries for spell material costs"
    t.index ["discarded_at"], name: "index_character_inventories_on_discarded_at"
    t.index ["equipment_sets"], name: "index_character_inventories_on_equipment_sets", using: :gin, comment: "Fast equipment set switching and loadout queries"
    t.index ["equipped_items"], name: "index_character_inventories_on_equipped_items", using: :gin, comment: "Fast equipped items lookups by slot"
    t.index ["inventory_grid"], name: "index_character_inventories_on_inventory_grid", using: :gin, comment: "Fast inventory grid searches for items and stacking"
  end

  create_table "character_items", force: :cascade do |t|
    t.integer "quantity"
    t.boolean "equipped"
    t.boolean "attuned"
    t.boolean "identified"
    t.text "notes"
    t.integer "character_id"
    t.integer "item_id"
    t.datetime "discarded_at"
    t.integer "lock_version", default: 0, null: false
    t.string "equipment_slot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_character_items_on_discarded_at"
  end

  create_table "character_notes", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "note_type"
    t.integer "character_id"
    t.datetime "discarded_at"
    t.string "note_category", default: "quick_note"
    t.jsonb "tags", default: []
    t.integer "session_number"
    t.date "session_date"
    t.string "priority", default: "medium"
    t.boolean "completed"
    t.datetime "completed_at"
    t.string "npc_name"
    t.string "relationship_status"
    t.string "faction_affiliation"
    t.date "last_interaction_date"
    t.jsonb "metadata", default: {}
    t.boolean "pinned"
    t.integer "character_limit", default: 5000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_character_notes_on_discarded_at"
  end

  create_table "character_progressions", force: :cascade do |t|
    t.integer "character_id", null: false
    t.jsonb "level_history", default: []
    t.jsonb "multiclass_levels", default: {}
    t.jsonb "feat_choices", default: []
    t.jsonb "asi_choices", default: []
    t.jsonb "subclass_features", default: {}
    t.jsonb "milestone_tracker", default: []
    t.integer "next_level_xp"
    t.string "progression_type"
    t.jsonb "planned_levels", default: []
    t.jsonb "xp_history", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "character_relationships", force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "related_character_id"
    t.string "relationship_type"
    t.integer "bond_strength", default: 50
    t.jsonb "shared_history", default: []
    t.jsonb "relationship_modifiers", default: {}
    t.text "notes"
    t.boolean "is_npc"
    t.string "npc_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "character_spell_managers", force: :cascade do |t|
    t.integer "character_id", null: false
    t.jsonb "spell_slots", default: {}
    t.jsonb "prepared_spells", default: []
    t.jsonb "known_spells", default: []
    t.jsonb "ritual_spells", default: []
    t.jsonb "spell_book", default: []
    t.string "spellcasting_ability"
    t.integer "spell_save_dc"
    t.integer "spell_attack_bonus"
    t.integer "cantrips_known", default: 0
    t.jsonb "concentration", default: {}
    t.integer "lock_version", default: 0, null: false
    t.integer "sorcery_points_max", default: 0
    t.integer "sorcery_points_current", default: 0
    t.jsonb "known_metamagics", default: []
    t.jsonb "metamagic_options", default: {}
    t.integer "wild_magic_surge_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["concentration"], name: "index_character_spell_managers_on_concentration", using: :gin, comment: "Fast active concentration spell lookups"
    t.index ["known_metamagics"], name: "index_character_spell_managers_on_known_metamagics", using: :gin, comment: "Fast metamagic option queries for Sorcerers"
    t.index ["known_spells"], name: "index_character_spell_managers_on_known_spells", using: :gin, comment: "Fast known spell queries for Sorcerers/Bards"
    t.index ["prepared_spells"], name: "index_character_spell_managers_on_prepared_spells", using: :gin, comment: "Fast prepared spell lookups"
    t.index ["spell_slots"], name: "index_character_spell_managers_on_spell_slots", using: :gin, comment: "Fast spell slot availability queries"
  end

  create_table "character_spells", force: :cascade do |t|
    t.boolean "known"
    t.boolean "prepared"
    t.boolean "always_prepared"
    t.integer "character_id"
    t.integer "spell_id"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_character_spells_on_discarded_at"
  end

  create_table "character_templates", force: :cascade do |t|
    t.string "name", null: false
    t.string "template_type"
    t.text "description"
    t.jsonb "template_data", default: {}
    t.integer "user_id"
    t.boolean "is_public"
    t.integer "usage_count", default: 0
    t.integer "rating_sum", default: 0
    t.integer "rating_count", default: 0
    t.jsonb "tags", default: []
    t.jsonb "compatible_classes", default: []
    t.integer "min_level"
    t.integer "max_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.integer "level"
    t.integer "experience"
    t.integer "proficiency_bonus"
    t.integer "strength"
    t.integer "dexterity"
    t.integer "constitution"
    t.integer "intelligence"
    t.integer "wisdom"
    t.integer "charisma"
    t.integer "hit_points_current"
    t.integer "hit_points_max"
    t.integer "temporary_hit_points"
    t.integer "armor_class"
    t.integer "initiative_bonus"
    t.integer "speed"
    t.string "alignment"
    t.text "personality_traits"
    t.text "ideals"
    t.text "bonds"
    t.text "flaws"
    t.text "backstory"
    t.jsonb "skills"
    t.jsonb "proficiencies"
    t.jsonb "conditions"
    t.string "avatar_url"
    t.string "visibility"
    t.datetime "deleted_at"
    t.integer "user_id"
    t.integer "campaign_id"
    t.integer "race_id"
    t.integer "character_class_id"
    t.integer "background_id"
    t.text "character_voice"
    t.jsonb "ai_personality_profile", default: {}
    t.jsonb "catchphrases", default: []
    t.jsonb "homebrew_modifications", default: {}
    t.jsonb "custom_features", default: []
    t.jsonb "house_rules", default: {}
    t.jsonb "quick_actions", default: []
    t.jsonb "favorite_spells", default: []
    t.jsonb "combat_tactics", default: []
    t.jsonb "theme_preferences", default: {}
    t.string "portrait_url"
    t.string "token_url"
    t.text "last_session_notes"
    t.integer "session_count", default: 0
    t.decimal "total_playtime_hours", default: "0.0"
    t.jsonb "faction_affiliations", default: {}, null: false
    t.jsonb "faction_reputations", default: {}, null: false
    t.integer "current_hp"
    t.integer "max_hp"
    t.integer "temporary_hp", default: 0, null: false
    t.integer "death_save_successes", default: 0, null: false
    t.integer "death_save_failures", default: 0, null: false
    t.jsonb "spell_slots", default: {}, null: false
    t.integer "concentration_spell_id"
    t.jsonb "damage_resistances", default: [], null: false
    t.jsonb "damage_immunities", default: [], null: false
    t.jsonb "damage_vulnerabilities", default: [], null: false
    t.jsonb "active_effects", default: []
    t.jsonb "resistances", default: []
    t.jsonb "immunities", default: []
    t.jsonb "vulnerabilities", default: []
    t.integer "hit_dice_used", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.integer "gold", default: 0, null: false
    t.index ["discarded_at"], name: "index_characters_on_discarded_at"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_session_id", null: false
    t.text "content", null: false
    t.string "message_type", default: "public"
    t.integer "recipient_id"
    t.integer "character_id"
    t.boolean "private"
    t.boolean "edited"
    t.boolean "deleted"
    t.string "deleted_by"
    t.text "original_content"
    t.jsonb "dice_results", default: []
    t.jsonb "mentions", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_chat_messages_on_discarded_at"
  end

  create_table "combat_actions", force: :cascade do |t|
    t.integer "round_number"
    t.string "action_type"
    t.integer "target_participant_id"
    t.text "description"
    t.integer "attack_roll"
    t.integer "damage_roll"
    t.string "damage_type"
    t.integer "healing_amount"
    t.integer "spell_id"
    t.integer "item_id"
    t.boolean "success"
    t.boolean "critical_hit"
    t.boolean "critical_fail"
    t.datetime "deleted_at"
    t.integer "combat_id"
    t.integer "combat_participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_combat_actions_on_discarded_at"
  end

  create_table "combat_encounters", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "game_session_id"
    t.string "status", default: "preparing", null: false
    t.integer "current_round", default: 0
    t.integer "current_turn", default: 0
    t.integer "current_turn_combatant_id"
    t.boolean "paused"
    t.integer "turn_timer_seconds"
    t.datetime "turn_started_at"
    t.datetime "started_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_combat_encounters_on_discarded_at"
  end

  create_table "combat_participants", force: :cascade do |t|
    t.integer "character_id"
    t.integer "initiative"
    t.integer "initiative_modifier"
    t.integer "current_hit_points"
    t.integer "max_hit_points"
    t.integer "temporary_hit_points"
    t.integer "armor_class"
    t.jsonb "conditions"
    t.string "concentrating_on"
    t.boolean "is_active"
    t.boolean "defeated"
    t.datetime "deleted_at"
    t.integer "combat_id"
    t.integer "encounter_monster_id"
    t.integer "death_save_successes", default: 0, null: false
    t.integer "death_save_failures", default: 0, null: false
    t.integer "actions_used", default: 0, null: false
    t.integer "bonus_actions_used", default: 0, null: false
    t.integer "reactions_used", default: 0, null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.integer "npc_id"
    t.index ["discarded_at"], name: "index_combat_participants_on_discarded_at"
    t.index ["npc_id"], name: "index_combat_participants_on_npc_id"
  end

  create_table "combatants", force: :cascade do |t|
    t.integer "combat_encounter_id", null: false
    t.integer "character_id"
    t.string "name"
    t.string "combatant_type", default: "pc", null: false
    t.integer "initiative"
    t.integer "dexterity"
    t.string "status", default: "conscious"
    t.integer "death_save_successes", default: 0
    t.integer "death_save_failures", default: 0
    t.integer "challenge_rating"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_combatants_on_discarded_at"
  end

  create_table "combats", force: :cascade do |t|
    t.integer "game_session_id"
    t.string "status"
    t.integer "current_round"
    t.integer "current_turn"
    t.datetime "started_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_combats_on_discarded_at"
  end

  create_table "conditions", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "effects"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_conditions_on_discarded_at"
  end

  create_table "content_clones", force: :cascade do |t|
    t.integer "shared_content_id", null: false
    t.integer "user_id", null: false
    t.string "cloned_content_type", null: false
    t.integer "cloned_content_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_content_clones_on_discarded_at"
  end

  create_table "content_libraries", force: :cascade do |t|
    t.integer "campaign_id"
    t.string "content_type"
    t.string "title"
    t.text "description"
    t.jsonb "content_data"
    t.jsonb "tags"
    t.boolean "ai_generated"
    t.string "ai_model"
    t.text "generation_prompt"
    t.boolean "is_public"
    t.integer "upvotes"
    t.integer "downvotes"
    t.integer "usage_count"
    t.decimal "quality_rating"
    t.boolean "reviewed"
    t.datetime "deleted_at"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_content_libraries_on_discarded_at"
  end

  create_table "content_ratings", force: :cascade do |t|
    t.integer "shared_content_id", null: false
    t.integer "user_id", null: false
    t.integer "rating", null: false
    t.text "review"
    t.integer "helpful_count", default: 0, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_content_ratings_on_discarded_at"
  end

  create_table "currents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "damage_logs", force: :cascade do |t|
    t.integer "combat_encounter_id", null: false
    t.string "source_type"
    t.integer "source_id"
    t.string "target_type"
    t.integer "target_id"
    t.integer "amount", null: false
    t.string "damage_type"
    t.text "description"
    t.integer "round_number"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_damage_logs_on_discarded_at"
  end

  create_table "dice_rolls", force: :cascade do |t|
    t.integer "character_id"
    t.integer "game_session_id"
    t.string "roll_type"
    t.string "dice_formula"
    t.jsonb "results"
    t.integer "total"
    t.integer "modifier"
    t.boolean "advantage"
    t.boolean "disadvantage"
    t.boolean "critical"
    t.string "context"
    t.datetime "deleted_at"
    t.integer "user_id"
    t.integer "combat_id"
    t.integer "combat_action_id"
    t.boolean "hidden", null: false
    t.boolean "active", default: true, null: false
    t.string "ability"
    t.text "metadata"
    t.string "state", default: "rolled", null: false
    t.boolean "locked", null: false
    t.integer "original_roll_id"
    t.integer "superseded_by_roll_id"
    t.text "reroll_reason"
    t.integer "dm_approved_by"
    t.datetime "dm_approved_at"
    t.datetime "reroll_requested_at"
    t.boolean "auto_confirmed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_dice_rolls_on_discarded_at"
  end

  create_table "dm_action_audit_logs", force: :cascade do |t|
    t.bigint "terminal_session_id", null: false
    t.bigint "character_id"
    t.bigint "dm_pending_action_id"
    t.string "tool_name", null: false
    t.jsonb "parameters", default: {}
    t.jsonb "result", default: {}
    t.string "execution_status", default: "executed", null: false
    t.jsonb "state_before", default: {}
    t.jsonb "state_after", default: {}
    t.integer "conversation_turn"
    t.string "trigger_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "execution_time_ms"
    t.index ["character_id"], name: "index_dm_action_audit_logs_on_character_id"
    t.index ["conversation_turn"], name: "index_dm_action_audit_logs_on_conversation_turn"
    t.index ["dm_pending_action_id"], name: "index_dm_action_audit_logs_on_dm_pending_action_id"
    t.index ["execution_status"], name: "index_dm_action_audit_logs_on_execution_status"
    t.index ["terminal_session_id", "conversation_turn"], name: "idx_on_terminal_session_id_conversation_turn_bb3e312073"
    t.index ["terminal_session_id"], name: "index_dm_action_audit_logs_on_terminal_session_id"
    t.index ["tool_name"], name: "index_dm_action_audit_logs_on_tool_name"
  end

  create_table "dm_pending_actions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "terminal_session_id", null: false
    t.bigint "character_id"
    t.bigint "user_id", null: false
    t.string "tool_name", null: false
    t.jsonb "parameters", default: {}
    t.text "description"
    t.text "dm_reasoning"
    t.string "status", default: "pending", null: false
    t.datetime "expires_at"
    t.datetime "reviewed_at"
    t.bigint "reviewed_by"
    t.text "player_response"
    t.jsonb "execution_result"
    t.text "error_message"
    t.string "batch_id"
    t.integer "batch_order"
    t.datetime "discarded_at"
    t.index ["batch_id"], name: "index_dm_pending_actions_on_batch_id"
    t.index ["character_id"], name: "index_dm_pending_actions_on_character_id"
    t.index ["discarded_at"], name: "index_dm_pending_actions_on_discarded_at"
    t.index ["expires_at"], name: "index_dm_pending_actions_on_expires_at"
    t.index ["status"], name: "index_dm_pending_actions_on_status"
    t.index ["terminal_session_id"], name: "index_dm_pending_actions_on_terminal_session_id"
    t.index ["user_id"], name: "index_dm_pending_actions_on_user_id"
  end

  create_table "dungeon_templates", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "dungeon_type"
    t.integer "min_party_level"
    t.integer "max_party_level"
    t.integer "room_count_min"
    t.integer "room_count_max"
    t.string "monster_density"
    t.string "trap_density"
    t.string "treasure_quality"
    t.jsonb "themes"
    t.jsonb "special_features"
    t.integer "created_by_user_id"
    t.boolean "is_public"
    t.integer "usage_count"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_dungeon_templates_on_discarded_at"
  end

  create_table "encounter_monsters", force: :cascade do |t|
    t.integer "quantity"
    t.integer "current_hit_points"
    t.integer "max_hit_points"
    t.integer "initiative"
    t.jsonb "conditions"
    t.text "notes"
    t.boolean "defeated"
    t.datetime "deleted_at"
    t.integer "encounter_id"
    t.integer "monster_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_encounter_monsters_on_discarded_at"
  end

  create_table "encounter_templates", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "min_party_level"
    t.integer "max_party_level"
    t.jsonb "monster_types"
    t.jsonb "terrain_types"
    t.decimal "difficulty_modifier"
    t.jsonb "environmental_hazards"
    t.jsonb "objectives"
    t.jsonb "rewards"
    t.integer "created_by_user_id"
    t.boolean "is_public"
    t.integer "usage_count"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_encounter_templates_on_discarded_at"
  end

  create_table "encounters", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "game_session_id"
    t.string "name"
    t.text "description"
    t.string "difficulty"
    t.string "status"
    t.integer "experience_awarded"
    t.text "treasure_awarded"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_encounters_on_discarded_at"
  end

  create_table "export_archives", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "user_id", null: false
    t.string "archive_type", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faction_memberships", force: :cascade do |t|
    t.integer "character_id"
    t.string "rank"
    t.string "title"
    t.integer "reputation"
    t.datetime "joined_at"
    t.datetime "left_at"
    t.string "status"
    t.jsonb "contributions"
    t.datetime "deleted_at"
    t.integer "faction_id"
    t.integer "npc_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_faction_memberships_on_discarded_at"
  end

  create_table "faction_relationships", force: :cascade do |t|
    t.integer "related_faction_id"
    t.string "relationship_type"
    t.integer "relationship_strength"
    t.text "history"
    t.jsonb "treaties"
    t.jsonb "conflicts"
    t.datetime "deleted_at"
    t.integer "faction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_faction_relationships_on_discarded_at"
  end

  create_table "factions", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "world_id"
    t.string "name"
    t.string "faction_type"
    t.integer "alignment_id"
    t.text "description"
    t.jsonb "goals"
    t.jsonb "resources"
    t.jsonb "territory"
    t.integer "power_level"
    t.integer "headquarters_location_id"
    t.integer "leader_npc_id"
    t.text "symbols"
    t.string "colors"
    t.string "motto"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_factions_on_discarded_at"
  end

  create_table "feats", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "prerequisites"
    t.jsonb "ability_score_increases", default: {}
    t.jsonb "benefits", default: {}
    t.string "source", default: "SRD"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "friend_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_friend_requests_on_discarded_at"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_friendships_on_discarded_at"
  end

  create_table "game_session_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_game_session_participants_on_discarded_at"
  end

  create_table "game_sessions", force: :cascade do |t|
    t.string "title"
    t.integer "session_number"
    t.datetime "scheduled_at"
    t.datetime "started_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_game_sessions_on_discarded_at"
  end

  create_table "generated_dungeons", force: :cascade do |t|
    t.integer "campaign_id"
    t.string "name"
    t.integer "party_level"
    t.integer "room_count"
    t.jsonb "layout_data"
    t.jsonb "room_descriptions"
    t.jsonb "monster_placements"
    t.jsonb "trap_locations"
    t.jsonb "treasure_locations"
    t.jsonb "secret_areas"
    t.string "boss_room_id"
    t.string "entrance_room_id"
    t.text "narrative_theme"
    t.string "difficulty_rating"
    t.datetime "generated_at"
    t.jsonb "explored_rooms"
    t.datetime "deleted_at"
    t.integer "dungeon_template_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_generated_dungeons_on_discarded_at"
  end

  create_table "generated_encounters", force: :cascade do |t|
    t.integer "campaign_id"
    t.string "name"
    t.integer "party_level"
    t.integer "party_size"
    t.string "difficulty_rating"
    t.integer "total_xp"
    t.jsonb "monsters_data"
    t.jsonb "terrain_features"
    t.jsonb "treasure"
    t.text "narrative_hook"
    t.text "tactics"
    t.datetime "generated_at"
    t.integer "used_in_encounter_id"
    t.datetime "deleted_at"
    t.integer "encounter_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_generated_encounters_on_discarded_at"
  end

  create_table "generated_treasures", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "character_id"
    t.integer "loot_table_id", null: false
    t.jsonb "treasure_data", default: {}
    t.datetime "generated_at"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_generated_treasures_on_discarded_at"
  end

  create_table "healing_logs", force: :cascade do |t|
    t.integer "combat_encounter_id", null: false
    t.string "source_type"
    t.integer "source_id"
    t.string "target_type"
    t.integer "target_id"
    t.integer "amount", null: false
    t.text "description"
    t.integer "round_number"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_healing_logs_on_discarded_at"
  end

  create_table "homebrew_items", force: :cascade do |t|
    t.integer "campaign_id"
    t.string "homebrew_type"
    t.string "name"
    t.text "description"
    t.jsonb "stat_block"
    t.string "source_reference"
    t.integer "balance_rating"
    t.boolean "published"
    t.integer "upvotes"
    t.datetime "deleted_at"
    t.integer "user_id"
    t.jsonb "content"
    t.string "visibility", default: "private"
    t.integer "version", default: 1
    t.string "tags"
    t.text "balance_notes"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_homebrew_items_on_discarded_at"
  end

  create_table "idempotent_requests", force: :cascade do |t|
    t.string "idempotency_key", null: false
    t.integer "character_id", null: false
    t.string "action_type", null: false
    t.jsonb "response_data"
    t.integer "status_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.string "item_type"
    t.string "rarity"
    t.text "description"
    t.jsonb "properties"
    t.decimal "weight"
    t.decimal "cost_gp"
    t.boolean "magic"
    t.boolean "requires_attunement"
    t.datetime "discarded_at"
    t.string "source"
    t.integer "armor_class"
    t.string "armor_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_items_on_discarded_at"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.string "script"
    t.text "typical_speakers"
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_languages_on_discarded_at"
  end

  create_table "locations", force: :cascade do |t|
    t.integer "world_id"
    t.integer "parent_location_id"
    t.string "name"
    t.string "location_type"
    t.text "description"
    t.integer "population"
    t.string "government_type"
    t.jsonb "notable_features"
    t.jsonb "shops"
    t.jsonb "taverns"
    t.jsonb "points_of_interest"
    t.string "climate"
    t.string "terrain"
    t.integer "coordinates_x"
    t.integer "coordinates_y"
    t.integer "danger_level"
    t.boolean "visited"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_locations_on_discarded_at"
  end

  create_table "loot_table_entries", force: :cascade do |t|
    t.integer "loot_table_id", null: false
    t.string "treasure_type", null: false
    t.string "quantity_dice"
    t.integer "weight", default: 1
    t.integer "item_id"
    t.jsonb "treasure_data", default: {}
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_loot_table_entries_on_discarded_at"
  end

  create_table "loot_tables", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "table_type"
    t.decimal "challenge_rating_min"
    t.decimal "challenge_rating_max"
    t.string "source"
    t.integer "user_id"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_loot_tables_on_discarded_at"
  end

  create_table "maps", force: :cascade do |t|
    t.integer "campaign_id"
    t.string "name"
    t.text "description"
    t.integer "grid_width"
    t.integer "grid_height"
    t.integer "grid_size"
    t.string "background_color"
    t.jsonb "terrain_data"
    t.boolean "fog_of_war_enabled"
    t.jsonb "fog_of_war_data"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_maps_on_discarded_at"
  end

  create_table "message_reactions", force: :cascade do |t|
    t.integer "chat_message_id", null: false
    t.integer "user_id", null: false
    t.string "emoji", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monster_abilities", force: :cascade do |t|
    t.string "name"
    t.string "ability_type"
    t.text "description"
    t.integer "attack_bonus"
    t.string "damage_dice"
    t.string "damage_type"
    t.integer "save_dc"
    t.string "save_ability"
    t.string "recharge"
    t.datetime "deleted_at"
    t.integer "monster_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_monster_abilities_on_discarded_at"
  end

  create_table "monsters", force: :cascade do |t|
    t.string "name"
    t.string "size"
    t.string "creature_type"
    t.integer "alignment_id"
    t.integer "armor_class"
    t.integer "hit_points"
    t.string "hit_dice"
    t.string "speed"
    t.integer "strength"
    t.integer "dexterity"
    t.integer "constitution"
    t.integer "intelligence"
    t.integer "wisdom"
    t.integer "charisma"
    t.decimal "challenge_rating"
    t.integer "experience_points"
    t.jsonb "skills"
    t.text "damage_vulnerabilities"
    t.text "damage_resistances"
    t.text "damage_immunities"
    t.text "condition_immunities"
    t.text "senses"
    t.text "languages"
    t.text "description"
    t.string "source"
    t.datetime "deleted_at"
    t.jsonb "saving_throws"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_monsters_on_discarded_at"
  end

  create_table "narrative_outputs", force: :cascade do |t|
    t.bigint "terminal_session_id", null: false
    t.text "content", null: false
    t.string "content_type", default: "narrative", null: false
    t.jsonb "clickable_elements", default: []
    t.text "rendered_html"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "memory_hints"
    t.string "speaker"
    t.integer "related_room_id"
    t.integer "related_npc_id"
    t.index ["content_type"], name: "index_narrative_outputs_on_content_type"
    t.index ["created_at"], name: "index_narrative_outputs_on_created_at"
    t.index ["terminal_session_id"], name: "index_narrative_outputs_on_terminal_session_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.string "notification_type", null: false
    t.string "title", null: false
    t.text "message", null: false
    t.string "priority", default: "medium", null: false
    t.jsonb "metadata", default: {}
    t.datetime "read_at"
    t.string "action_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "npc_interactions", force: :cascade do |t|
    t.integer "character_id"
    t.integer "game_session_id"
    t.string "interaction_type"
    t.text "summary"
    t.text "player_action"
    t.text "npc_response"
    t.integer "relationship_change"
    t.integer "quest_log_id"
    t.jsonb "metadata"
    t.datetime "occurred_at"
    t.datetime "deleted_at"
    t.integer "npc_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_npc_interactions_on_discarded_at"
  end

  create_table "npcs", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "world_id"
    t.string "name"
    t.integer "race_id"
    t.integer "character_class_id"
    t.string "occupation"
    t.integer "age"
    t.integer "alignment_id"
    t.text "personality_traits"
    t.text "ideals"
    t.text "bonds"
    t.text "flaws"
    t.string "voice_style"
    t.text "speech_patterns"
    t.jsonb "motivations"
    t.jsonb "secrets"
    t.jsonb "relationships"
    t.string "status"
    t.text "backstory"
    t.jsonb "ai_personality_profile"
    t.jsonb "conversation_memory"
    t.string "importance_level"
    t.datetime "deleted_at"
    t.integer "faction_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.integer "strength", default: 10
    t.integer "dexterity", default: 10
    t.integer "constitution", default: 10
    t.integer "intelligence", default: 10
    t.integer "wisdom", default: 10
    t.integer "charisma", default: 10
    t.integer "armor_class", default: 10
    t.integer "hit_points"
    t.integer "max_hit_points"
    t.string "hit_dice"
    t.integer "level", default: 1
    t.integer "proficiency_bonus", default: 2
    t.jsonb "saving_throws", default: {}
    t.jsonb "skills", default: {}
    t.text "damage_resistances"
    t.text "damage_immunities"
    t.text "condition_immunities"
    t.integer "speed", default: 30
    t.decimal "challenge_rating", precision: 4, scale: 2
    t.integer "initiative"
    t.text "conditions"
    t.index ["discarded_at"], name: "index_npcs_on_discarded_at"
  end

  create_table "player_engagements", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "character_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_player_engagements_on_discarded_at"
  end

  create_table "plot_hooks", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "created_by_user_id"
    t.string "title"
    t.text "description"
    t.string "hook_type"
    t.string "urgency"
    t.string "complexity"
    t.integer "suggested_level_min"
    t.integer "suggested_level_max"
    t.jsonb "factions_involved"
    t.jsonb "npcs_involved"
    t.jsonb "locations_involved"
    t.jsonb "rewards_suggested"
    t.jsonb "complications"
    t.string "status"
    t.integer "converted_to_quest_id"
    t.boolean "ai_generated"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_plot_hooks_on_discarded_at"
  end

  create_table "quest_logs", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "character_id"
    t.string "title"
    t.text "description"
    t.string "status"
    t.string "quest_type"
    t.string "difficulty"
    t.integer "experience_reward"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.integer "priority", default: 0
    t.integer "gold_reward", default: 0
    t.jsonb "item_rewards", default: []
    t.jsonb "prerequisites", default: {}
    t.integer "quest_chain_id"
    t.integer "parent_quest_id"
    t.string "location"
    t.jsonb "npc_ids", default: []
    t.boolean "assigned_to_party"
    t.jsonb "milestone_data", default: {}
    t.integer "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.integer "presentation_count", default: 0
    t.datetime "last_presented_at"
    t.boolean "consequence_applied", default: false
    t.integer "escalation_level", default: 0
    t.string "resolution_type"
    t.index ["discarded_at"], name: "index_quest_logs_on_discarded_at"
  end

  create_table "quest_objectives", force: :cascade do |t|
    t.string "description"
    t.integer "order_index"
    t.boolean "completed"
    t.boolean "optional"
    t.integer "progress_current"
    t.integer "progress_target"
    t.datetime "deleted_at"
    t.integer "quest_log_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_quest_objectives_on_discarded_at"
  end

  create_table "quest_templates", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "quest_type"
    t.string "difficulty"
    t.jsonb "objectives"
    t.jsonb "rewards"
    t.jsonb "prerequisites"
    t.string "icon"
    t.string "color"
    t.string "category"
    t.integer "estimated_duration_minutes"
    t.integer "min_party_level"
    t.integer "max_party_level"
    t.jsonb "location_tags"
    t.jsonb "npc_tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quick_actions", force: :cascade do |t|
    t.bigint "terminal_session_id", null: false
    t.string "label", null: false
    t.string "action_type", null: false
    t.string "target_id"
    t.jsonb "params", default: {}
    t.string "tooltip"
    t.string "keyboard_shortcut"
    t.boolean "requires_roll", default: false
    t.string "skill_check"
    t.integer "dc"
    t.boolean "is_available", default: true
    t.integer "sort_order", default: 0
    t.datetime "cooldown_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_quick_actions_on_action_type"
    t.index ["is_available"], name: "index_quick_actions_on_is_available"
    t.index ["terminal_session_id"], name: "index_quick_actions_on_terminal_session_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "name"
    t.string "size"
    t.integer "speed"
    t.jsonb "ability_increases"
    t.jsonb "traits"
    t.jsonb "languages"
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_races_on_discarded_at"
  end

  create_table "session_presences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_session_id", null: false
    t.string "status", default: "offline", null: false
    t.integer "connection_count", default: 0, null: false
    t.datetime "last_activity_at"
    t.datetime "disconnected_at"
    t.string "status_message"
    t.boolean "manual_status", null: false
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "session_recaps", force: :cascade do |t|
    t.integer "game_session_id"
    t.integer "generated_by_user_id"
    t.text "summary"
    t.jsonb "key_events"
    t.jsonb "npcs_met"
    t.jsonb "locations_visited"
    t.text "combat_summary"
    t.integer "experience_gained"
    t.text "treasure_found"
    t.jsonb "quests_updated"
    t.boolean "auto_generated"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_session_recaps_on_discarded_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shared_contents", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "content_type", null: false
    t.integer "content_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "visibility", default: "public", null: false
    t.string "license_type", default: "cc_by", null: false
    t.integer "view_count", default: 0, null: false
    t.integer "clone_count", default: 0, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_shared_contents_on_discarded_at"
  end

  create_table "solo_game_states", force: :cascade do |t|
    t.string "current_scene"
    t.string "current_location"
    t.string "time_of_day"
    t.string "weather"
    t.boolean "combat_active"
    t.jsonb "scene_data"
    t.jsonb "npcs_present"
    t.jsonb "active_quests"
    t.jsonb "inventory_state"
    t.jsonb "resources"
    t.integer "solo_session_id"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_solo_game_states_on_discarded_at"
  end

  create_table "solo_sessions", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_solo_sessions_on_discarded_at"
  end

  create_table "spell_filter_presets", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", null: false
    t.text "description"
    t.jsonb "filter_data", default: {}, null: false
    t.boolean "is_default", null: false
    t.boolean "is_public", null: false
    t.string "preset_type", default: "custom", null: false
    t.integer "usage_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spells", force: :cascade do |t|
    t.string "name"
    t.integer "level"
    t.string "school"
    t.string "casting_time"
    t.string "range"
    t.jsonb "components"
    t.string "duration"
    t.boolean "concentration"
    t.boolean "ritual"
    t.text "description"
    t.text "higher_levels"
    t.jsonb "classes"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_spells_on_discarded_at"
  end

  create_table "template_ratings", force: :cascade do |t|
    t.integer "campaign_template_id", null: false
    t.integer "user_id", null: false
    t.integer "rating", null: false
    t.text "review"
    t.integer "helpful_count", default: 0, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_template_ratings_on_discarded_at"
  end

  create_table "terminal_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "mode", default: "exploration"
    t.boolean "active", default: true
    t.bigint "character_id"
    t.bigint "dungeon_map_id"
    t.bigint "solo_session_id"
    t.string "map_render_mode", default: "ascii"
    t.boolean "show_map_panel", default: true
    t.jsonb "command_history", default: []
    t.jsonb "settings", default: {}
    t.string "discord_channel_id"
    t.string "discord_guild_id"
    t.string "discord_thread_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "session_token"
    t.integer "campaign_id"
    t.string "current_room", default: "lobby"
    t.datetime "game_started_at"
    t.boolean "character_locked", default: false
    t.jsonb "room_history", default: []
    t.index ["active"], name: "index_terminal_sessions_on_active"
    t.index ["campaign_id"], name: "index_terminal_sessions_on_campaign_id"
    t.index ["character_id"], name: "index_terminal_sessions_on_character_id"
    t.index ["discord_channel_id"], name: "index_terminal_sessions_on_discord_channel_id"
    t.index ["dungeon_map_id"], name: "index_terminal_sessions_on_dungeon_map_id"
    t.index ["solo_session_id"], name: "index_terminal_sessions_on_solo_session_id"
    t.index ["user_id"], name: "index_terminal_sessions_on_user_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.integer "character_id"
    t.string "name"
    t.string "token_type"
    t.integer "grid_x"
    t.integer "grid_y"
    t.string "size"
    t.string "color"
    t.string "icon"
    t.boolean "visible_to_players"
    t.integer "current_hit_points"
    t.integer "max_hit_points"
    t.datetime "deleted_at"
    t.integer "map_id"
    t.integer "encounter_monster_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_tokens_on_discarded_at"
  end

  create_table "user_blocks", force: :cascade do |t|
    t.integer "blocker_id", null: false
    t.integer "blocked_id", null: false
    t.string "reason"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_user_blocks_on_discarded_at"
  end

  create_table "user_theme_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "primary_color"
    t.string "secondary_color"
    t.string "accent_color"
    t.string "background_color"
    t.string "text_color"
    t.boolean "dark_mode", null: false
    t.boolean "high_contrast", null: false
    t.boolean "reduced_motion", null: false
    t.string "font_size", default: "medium"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.string "role", default: "user"
    t.datetime "discarded_at"
    t.string "username"
    t.text "bio"
    t.string "avatar_url"
    t.integer "experience_points"
    t.integer "level"
    t.string "preferences"
    t.string "timezone"
    t.datetime "last_active_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "guest", default: false
    t.string "display_name"
    t.string "discord_id"
    t.string "discord_username"
    t.string "discord_discriminator"
    t.string "discord_avatar"
    t.string "discord_access_token"
    t.string "discord_refresh_token"
    t.datetime "discord_token_expires_at"
    t.integer "ai_tokens_used", default: 0
    t.integer "ai_tokens_limit", default: 100000
    t.datetime "ai_tokens_reset_at"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["discord_id"], name: "index_users_on_discord_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "vtt_maps", force: :cascade do |t|
    t.integer "vtt_session_id", null: false
    t.string "background_url", null: false
    t.integer "width", default: 30, null: false
    t.integer "height", default: 20, null: false
    t.boolean "grid_overlay", default: true, null: false
    t.jsonb "terrain_features", default: []
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vtt_sessions", force: :cascade do |t|
    t.integer "game_session_id", null: false
    t.integer "campaign_id", null: false
    t.integer "location_id"
    t.integer "encounter_id"
    t.integer "grid_size", default: 50, null: false
    t.string "grid_type", default: "square", null: false
    t.decimal "zoom_level", default: "1.0"
    t.boolean "active", default: true, null: false
    t.integer "round_number", default: 0
    t.jsonb "state_snapshot", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vtt_tokens", force: :cascade do |t|
    t.integer "vtt_session_id", null: false
    t.integer "character_id"
    t.integer "npc_id"
    t.integer "monster_id"
    t.decimal "x", default: "0.0", null: false
    t.decimal "y", default: "0.0", null: false
    t.integer "rotation", default: 0, null: false
    t.boolean "hidden", null: false
    t.string "size", default: "medium", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weapons", force: :cascade do |t|
    t.string "name", null: false
    t.string "damage_dice", null: false
    t.string "damage_type"
    t.jsonb "properties", default: []
    t.string "versatile_damage"
    t.integer "character_id"
    t.integer "item_id"
    t.boolean "active", default: true
    t.boolean "equipped"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_weapons_on_discarded_at"
  end

  create_table "world_lore_entries", force: :cascade do |t|
    t.string "title"
    t.string "entry_type"
    t.text "content"
    t.jsonb "tags"
    t.jsonb "metadata"
    t.string "visibility"
    t.integer "created_by_id"
    t.datetime "deleted_at"
    t.integer "world_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_world_lore_entries_on_discarded_at"
  end

  create_table "worlds", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "settings"
    t.integer "creator_id"
    t.string "visibility"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_worlds_on_discarded_at"
  end

  add_foreign_key "combat_participants", "npcs"
  add_foreign_key "dm_action_audit_logs", "characters"
  add_foreign_key "dm_action_audit_logs", "dm_pending_actions"
  add_foreign_key "dm_action_audit_logs", "terminal_sessions"
  add_foreign_key "dm_pending_actions", "characters"
  add_foreign_key "dm_pending_actions", "terminal_sessions"
  add_foreign_key "dm_pending_actions", "users"
  add_foreign_key "narrative_outputs", "terminal_sessions"
  add_foreign_key "quick_actions", "terminal_sessions"
  add_foreign_key "terminal_sessions", "campaigns"
  add_foreign_key "terminal_sessions", "characters"
  add_foreign_key "terminal_sessions", "maps", column: "dungeon_map_id"
  add_foreign_key "terminal_sessions", "solo_sessions"
  add_foreign_key "terminal_sessions", "users"
end
