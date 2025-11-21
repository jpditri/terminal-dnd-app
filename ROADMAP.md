# Terminal D&D - Development Roadmap

## Overview
Total TODOs in codebase: **732**

Most TODOs are stub implementations for future features. This roadmap prioritizes items critical to core functionality, user experience, and security.

---

## Priority 1: Critical for Core Solo Play (IMMEDIATE)

### 1.1 Equipment & Armor System
**Priority:** HIGH
**Impact:** Core gameplay mechanics
**File:** `app/models/character.rb:75`

**Current State:**
```ruby
def calculated_armor_class
  # TODO: Add armor bonuses when equipment system is implemented
  10 + dexterity_modifier
end
```

**Requirements:**
- Implement armor items with AC bonuses
- Add equipment slots (armor, shield, helmet, etc.)
- Calculate total AC from worn equipment
- Handle armor proficiency restrictions

**Estimated Effort:** 2-3 hours

---

### 1.2 Tab Completion for Terminal
**Priority:** HIGH
**Impact:** Critical UX improvement
**File:** `app/javascript/controllers/terminal_controller.js:175`

**Current State:**
```javascript
autocomplete() {
  const input = this.inputTarget.value
  // TODO: Implement tab completion for commands
}
```

**Requirements:**
- Command name completion for `/` commands
- NPC name completion
- Item name completion from inventory
- Location/room name completion
- Smart context-aware suggestions

**Estimated Effort:** 3-4 hours

---

### 1.3 Map Authorization
**Priority:** MEDIUM
**Impact:** Prevents cheating in multiplayer
**File:** `app/channels/map_channel.rb:76`

**Current State:**
```ruby
# TODO: Add authorization check for DM
```

**Requirements:**
- Only DM can modify maps
- Players can view but not edit
- Fog of war respects player permissions

**Estimated Effort:** 1-2 hours

---

## Priority 2: Authentication & Security (HIGH PRIORITY)

### 2.1 Authentication Scaffolding
**Priority:** HIGH (Security)
**Impact:** ~90 controllers need authentication
**Affected Files:** Most controllers

**Problem:** Many controllers have stub authentication:
```ruby
# TODO: Implement require_authentication
# TODO: Implement set_user
```

**Solution:**
- Implement base `require_authentication` before_action in ApplicationController
- Use Devise or similar for user sessions
- Add `current_user` helper
- Protect all non-public endpoints

**Estimated Effort:** 4-6 hours
**Urgency:** Required before any multi-user deployment

---

## Priority 3: Feature Completion (MEDIUM)

### 3.1 Multiplayer Systems (30 TODOs)
**Status:** Completely unimplemented
**Services affected:**
- `multiplayer/combat_synchronizer.rb` - Sync combat across players
- `multiplayer/dice_broadcaster.rb` - Share dice rolls
- `multiplayer/rules_explainer.rb` - Collaborative rules lookups

**Decision Point:**
- **Option A:** Complete multiplayer (requires authentication first)
- **Option B:** Focus on solo play, defer multiplayer to v2.0

**Recommendation:** Defer to v2.0, focus on polished solo experience

---

### 3.2 AI Character Services (40+ TODOs)
**Status:** Service stubs exist but not implemented
**Services:**
- `ai_assistant_service.rb` - Character-specific AI help
- `ai_context_builder_service.rb` - Build context for AI suggestions
- `ai_consistency_checker_service.rb` - Validate character consistency
- `growth_analysis_service.rb` - Track character development
- `session_recap_service.rb` - Generate session summaries

**Recommendation:** Low priority - core AI DM already works

---

### 3.3 Campaign Analytics (16 TODOs)
**File:** `app/services/campaign_analytics_service.rb`
**Status:** Stub service for metrics/analytics

**Recommendation:** Low priority - nice-to-have, not core gameplay

---

### 3.4 VTT Services (5 services, multiple TODOs)
**Services:**
- `vtt_combat_suggestion_service.rb`
- `vtt_encounter_evolution_service.rb`
- `vtt_map_generator_service.rb`
- `vtt_spell_narration_service.rb`
- `vtt_tactical_positioning_service.rb`

**Status:** Virtual Tabletop features for advanced combat visualization

**Recommendation:** Medium priority - enhance combat experience

---

## Priority 4: Test Coverage (LOW)

### 4.1 Model Scope Tests
**Count:** ~500 missing scope tests in spec files
**Pattern:** `# TODO: Add scope test`

**Recommendation:** Low priority - most are auto-generated RSpec stubs

---

## Recommended Roadmap

### Phase 1: Solo Play Polish (Next 2 Weeks)
**Goal:** Polished, complete solo play experience

1. **Equipment System** (2-3 hours)
   - Armor, weapons, shield AC calculations
   - Equipment proficiency checks
   - Inventory weight tracking

2. **Tab Completion** (3-4 hours)
   - Command completion
   - Context-aware suggestions
   - History navigation improvements

3. **Room Transition Flow** (2-3 hours)
   - Visual room indicators in UI
   - Smooth transitions between rooms
   - `/goto` and `/back` commands fully functional

4. **Character Creation Flow** (2-3 hours)
   - Guided multi-step creation
   - Background selection
   - Starting equipment allocation

5. **Combat Polish** (3-4 hours)
   - Initiative tracking
   - Action economy (action, bonus action, reaction)
   - Condition tracking UI

**Total:** 12-17 hours of focused development

---

### Phase 2: Authentication & Multi-User (1 Week)
**Goal:** Secure multi-user deployment ready

1. **Authentication System** (4-6 hours)
   - Devise integration
   - Session management
   - Role-based authorization (player/DM)

2. **Authorization Layer** (3-4 hours)
   - Controller-level checks
   - Resource ownership validation
   - DM permissions for campaigns

3. **User Management** (2-3 hours)
   - Registration/login flows
   - Password reset
   - Profile management

**Total:** 9-13 hours

---

### Phase 3: Multiplayer Foundation (2-3 Weeks)
**Goal:** Basic multiplayer campaigns

1. **Combat Synchronizer** (6-8 hours)
   - Real-time combat state sync
   - Turn order management
   - Action broadcasting

2. **Dice Broadcaster** (3-4 hours)
   - Share roll results
   - Roll history/log
   - Verification for trust

3. **Chat System** (4-6 hours)
   - Player-to-player chat
   - DM whispers
   - In-character/out-of-character modes

**Total:** 13-18 hours

---

### Phase 4: Advanced Features (Future)
**Goal:** Rich feature set

1. **VTT Enhancements**
   - Spell visual effects
   - Tactical grid improvements
   - Token management

2. **AI Character Assistants**
   - Character-specific AI help
   - Growth analysis
   - Consistency checking

3. **Campaign Analytics**
   - Player engagement metrics
   - Session quality tracking
   - DM dashboard

---

## Immediate Next Steps (This Week)

### Must-Do
1. ✅ **Equipment System** - Add armor/AC calculations
2. ✅ **Tab Completion** - Dramatically improve terminal UX
3. ✅ **Room UI Indicators** - Show current room, lock status

### Should-Do
4. **Character Creation Wizard** - Multi-step guided flow
5. **Starting Equipment** - Allocate items by class/background

### Nice-to-Have
6. **Combat Initiative UI** - Visual turn order
7. **Condition Badges** - Show active conditions on character

---

## Scope Reduction Recommendations

### Remove/Defer (Not Critical for Solo Play)
- **Entire Multiplayer Stack** - 30 TODOs → Defer to v2.0
- **AI Character Services** - 40+ TODOs → Defer, AI DM is sufficient
- **Campaign Analytics** - 16 TODOs → Defer, nice-to-have only
- **VTT Advanced Features** - Defer most, keep basic map
- **Homebrew Balance Analyzers** - Low priority

**Impact:** Reduces TODO count from 732 → ~100 for v1.0 scope

---

## Success Metrics for v1.0

### Core Functionality
- ✅ Complete character creation with equipment
- ✅ Working combat system with initiative/actions
- ✅ AI DM with narrative-first approach
- ✅ Room-based state management
- ✅ Instant command responses

### User Experience
- ⏳ Tab completion for all commands
- ⏳ Smooth room transitions
- ✅ Quick actions that update contextually
- ✅ Split-pane display for stats
- ⏳ Visual feedback for character lock state

### Technical Quality
- ⏳ Authentication system in place
- ⏳ No security vulnerabilities
- ✅ Clean separation of concerns
- ✅ Command preprocessing layer
- ⏳ Comprehensive test coverage for core features

---

## Decision Points

### Q1: Multiplayer vs Solo Focus?
**Recommendation:** Focus on polished solo experience first. Multiplayer adds 10x complexity.

### Q2: Which AI services to implement?
**Recommendation:** AI DM is sufficient. Defer character-specific AI assistants.

### Q3: VTT depth?
**Recommendation:** Basic ASCII/SVG maps only. Defer advanced tactical features.

### Q4: Test coverage depth?
**Recommendation:** Focus on integration tests for user flows, not exhaustive unit tests for every scope.

---

## Next Session Action Items

1. Implement equipment/armor system
2. Add tab completion
3. Add visual room indicators in UI
4. Implement character creation wizard
5. Add starting equipment allocation

**Estimated Time:** One focused development session (8-10 hours)
