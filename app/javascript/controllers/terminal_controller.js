import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = [
    "input",
    "narrativeOutput",
    "quickActions",
    "mapPanel",
    "mapDisplay",
    "mapAscii",
    "mapCanvas",
    "tooltip",
    "contextMenu",
    "clock",
    "pendingActions",
    "characterStatus",
    "suggestionsPanel"
  ]

  static values = {
    sessionId: Number,
    mapId: Number
  }

  connect() {
    this.commandHistory = []
    this.historyIndex = -1
    this.pendingApprovals = []
    this.consumer = createConsumer()

    // Subscribe to AI DM channel
    this.terminalChannel = this.consumer.subscriptions.create(
      { channel: "TerminalDmChannel", session_id: this.sessionIdValue },
      {
        received: (data) => this.handleTerminalMessage(data),
        connected: () => {
          console.log("Terminal DM connected")
          this.appendNarrative('system', 'Connected to AI Dungeon Master. Type /help for commands or just start talking!')
        },
        disconnected: () => {
          console.log("Terminal DM disconnected")
          this.appendNarrative('error', 'Disconnected from server. Attempting to reconnect...')
        }
      }
    )

    // Subscribe to map channel if map exists
    if (this.mapIdValue) {
      this.mapChannel = this.consumer.subscriptions.create(
        { channel: "MapChannel", map_id: this.mapIdValue },
        {
          received: (data) => this.handleMapMessage(data),
          connected: () => console.log("Map connected")
        }
      )
    }

    // Focus input
    this.inputTarget.focus()

    // Scroll to bottom
    this.scrollToBottom()

    // Start clock
    this.startClock()

    // Keyboard shortcuts
    document.addEventListener('keydown', this.handleGlobalKeydown.bind(this))
  }

  disconnect() {
    if (this.terminalChannel) this.terminalChannel.unsubscribe()
    if (this.mapChannel) this.mapChannel.unsubscribe()
    if (this.clockInterval) clearInterval(this.clockInterval)
    document.removeEventListener('keydown', this.handleGlobalKeydown.bind(this))
  }

  // ========================================
  // Input Handling
  // ========================================

  handleKeydown(event) {
    switch (event.key) {
      case 'Enter':
        this.submitInput()
        break
      case 'ArrowUp':
        event.preventDefault()
        this.navigateHistory(-1)
        break
      case 'ArrowDown':
        event.preventDefault()
        this.navigateHistory(1)
        break
      case 'Tab':
        event.preventDefault()
        this.autocomplete()
        break
      case 'Escape':
        this.hideContextMenu()
        this.hideTooltip()
        break
    }
  }

  handleGlobalKeydown(event) {
    // Quick action shortcuts (1-9)
    if (event.key >= '1' && event.key <= '9' && !event.ctrlKey && !event.metaKey) {
      if (document.activeElement !== this.inputTarget) {
        const index = parseInt(event.key) - 1
        const actions = this.quickActionsTarget.querySelectorAll('.quick-action')
        if (actions[index]) {
          event.preventDefault()
          actions[index].click()
        }
      }
    }

    // Toggle map with 'm'
    if (event.key === 'm' && event.ctrlKey) {
      event.preventDefault()
      this.toggleMap()
    }

    // Focus input with '/'
    if (event.key === '/' && document.activeElement !== this.inputTarget) {
      event.preventDefault()
      this.inputTarget.focus()
    }
  }

  submitInput() {
    const input = this.inputTarget.value.trim()
    if (!input) return

    // Add to history
    this.commandHistory.push(input)
    this.historyIndex = this.commandHistory.length

    // Clear input
    this.inputTarget.value = ''

    // Display user input
    this.appendNarrative('user', `> ${input}`)

    // Process input
    if (input.startsWith('/')) {
      this.processCommand(input)
    } else {
      this.processAction(input)
    }
  }

  navigateHistory(direction) {
    const newIndex = this.historyIndex + direction

    if (newIndex < 0) {
      this.historyIndex = 0
      return
    }

    if (newIndex >= this.commandHistory.length) {
      this.historyIndex = this.commandHistory.length
      this.inputTarget.value = ''
      return
    }

    this.historyIndex = newIndex
    this.inputTarget.value = this.commandHistory[this.historyIndex]
  }

  autocomplete() {
    const input = this.inputTarget.value
    // TODO: Implement tab completion for commands
  }

  // ========================================
  // Command Processing
  // ========================================

  processCommand(input) {
    const [command, ...args] = input.slice(1).split(' ')

    switch (command.toLowerCase()) {
      case 'help':
        this.showHelp()
        break
      case 'create':
        this.startCharacterCreation()
        break
      case 'load':
        this.loadCharacter(args[0])
        break
      case 'map':
        this.mapCommand(args)
        break
      case 'roll':
        this.rollDice(args.join(' '))
        break
      case 'inventory':
      case 'inv':
        this.showInventory()
        break
      case 'character':
      case 'char':
        this.showCharacter()
        break
      case 'rest':
        this.rest(args[0])
        break
      case 'save':
        this.saveGame()
        break
      case 'quit':
        this.quitGame()
        break
      default:
        this.appendNarrative('error', `Unknown command: /${command}`)
        this.appendNarrative('system', 'Type /help for available commands.')
    }
  }

  processAction(input) {
    // Clear quick actions before sending new message
    this.clearQuickActions()

    // Send to AI DM for processing
    this.terminalChannel.perform('send_message', { message: input })

    // Show loading indicator
    this.showLoading()
  }

  // ========================================
  // Quick Actions
  // ========================================

  executeQuickAction(event) {
    const button = event.currentTarget
    const action = button.dataset.actionType
    const params = JSON.parse(button.dataset.params || '{}')

    // Handle send_message directly in frontend
    if (action === 'send_message' && params.message) {
      this.inputTarget.value = params.message
      this.sendMessage()
      return
    }

    // Other actions go through the channel
    this.terminalChannel.perform('quick_action', {
      action: action,
      params: params
    })

    this.showLoading()
  }

  updateQuickActions(actions) {
    this.quickActionsTarget.innerHTML = actions.map((action, i) => `
      <button class="quick-action"
              data-action="click->terminal#executeQuickAction"
              data-action-type="${action.action_type}"
              data-target-id="${action.target_id || ''}"
              data-params='${JSON.stringify(action.params || {})}'>
        ${action.label}
        ${i < 9 ? `<span class="shortcut">[${i + 1}]</span>` : ''}
      </button>
    `).join('')
  }

  clearQuickActions() {
    this.quickActionsTarget.innerHTML = ''
  }

  // ========================================
  // Side Panel (tmux-style split)
  // ========================================

  toggleSidePanel() {
    if (!this.hasSidePanelTarget) return

    const isHidden = this.sidePanelTarget.classList.contains('hidden')

    if (isHidden) {
      this.sidePanelTarget.classList.remove('hidden')
      this.mainContentTarget.classList.add('split-mode')
    } else {
      this.sidePanelTarget.classList.add('hidden')
      this.mainContentTarget.classList.remove('split-mode')
    }
  }

  showCharacterSheet(data) {
    if (!this.hasSidePanelTarget) return

    const char = data.character
    if (!char) return

    this.sidePanelTitleTarget.textContent = `${char.name} - Character Sheet`

    const content = `
      <div class="stat-block">
        <div class="stat-header">▸ Core Stats</div>
        <div class="stat-row">
          <span class="stat-label">Level</span>
          <span class="stat-value">${char.level}</span>
        </div>
        <div class="stat-row">
          <span class="stat-label">Race</span>
          <span class="stat-value">${char.race || 'Unknown'}</span>
        </div>
        <div class="stat-row">
          <span class="stat-label">Class</span>
          <span class="stat-value">${char.class || 'Unknown'}</span>
        </div>
      </div>

      <div class="stat-block">
        <div class="stat-header">▸ Hit Points</div>
        <div class="stat-row">
          <span class="stat-label">Current HP</span>
          <span class="stat-value">${char.hp}/${char.max_hp}</span>
        </div>
        <div class="stat-row">
          <span class="stat-label">Armor Class</span>
          <span class="stat-value">${char.ac}</span>
        </div>
      </div>

      <div class="stat-block">
        <div class="stat-header">▸ Resources</div>
        <div class="stat-row">
          <span class="stat-label">Gold</span>
          <span class="stat-value">${char.gold} gp</span>
        </div>
        <div class="stat-row">
          <span class="stat-label">Experience</span>
          <span class="stat-value">${char.xp} XP</span>
        </div>
      </div>

      ${char.conditions && char.conditions.length > 0 ? `
      <div class="stat-block">
        <div class="stat-header">▸ Conditions</div>
        ${char.conditions.map(c => `
          <div class="stat-row">
            <span class="stat-value">${c}</span>
          </div>
        `).join('')}
      </div>
      ` : ''}
    `

    this.sidePanelContentTarget.innerHTML = content

    // Show the panel if it's hidden
    if (this.sidePanelTarget.classList.contains('hidden')) {
      this.toggleSidePanel()
    }
  }

  showStatBlock(data) {
    if (!this.hasSidePanelTarget) return

    this.sidePanelTitleTarget.textContent = data.title || 'Stat Block'
    this.sidePanelContentTarget.innerHTML = `<pre>${data.content}</pre>`

    // Show the panel if it's hidden
    if (this.sidePanelTarget.classList.contains('hidden')) {
      this.toggleSidePanel()
    }
  }

  // ========================================
  // Map Controls
  // ========================================

  toggleMap() {
    if (this.hasMapPanelTarget) {
      this.mapPanelTarget.classList.toggle('hidden')
    }
  }

  setMapMode(event) {
    const mode = event.currentTarget.dataset.mode

    // Update active button
    this.mapPanelTarget.querySelectorAll('.map-controls button').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.mode === mode)
    })

    // Request new render from server
    if (this.mapChannel) {
      this.mapChannel.perform('set_render_mode', { mode: mode })
    }
  }

  exportMap() {
    if (this.mapChannel) {
      this.mapChannel.perform('export_map', { format: 'ascii' })
    }
  }

  mapCommand(args) {
    const subcommand = args[0]

    switch (subcommand) {
      case 'generate':
        const template = args[1] || 'small_dungeon'
        this.terminalChannel.perform('generate_map', { template: template })
        break
      case 'toggle':
        this.toggleMap()
        break
      case 'fog':
        const mode = args[1] || 'partial'
        if (this.mapChannel) {
          this.mapChannel.perform('set_fog_mode', { mode: mode })
        }
        break
      case 'export':
        this.exportMap()
        break
      default:
        this.appendNarrative('system', 'Map commands: generate [template], toggle, fog [mode], export')
    }
  }

  // ========================================
  // Narrative Display
  // ========================================

  appendNarrative(type, content, options = {}) {
    const entry = document.createElement('div')
    entry.className = `narrative-entry ${type}`

    // Check if content is HTML (either explicitly marked or starts with HTML tag)
    const isHtml = options.isHtml || content.trim().startsWith('<')

    // Convert clickables to quick actions instead of inline
    if (options.clickables && options.clickables.length > 0) {
      const quickActions = options.clickables.map(c => ({
        action_type: c.action,
        label: c.text,
        target_id: c.id
      }))
      this.updateQuickActions(quickActions)
    }

    if (isHtml) {
      // Content is already rendered HTML, use directly
      entry.innerHTML = content
    } else {
      // Plain text, escape and wrap in paragraph
      entry.innerHTML = `<p>${this.escapeHtml(content)}</p>`
    }

    this.narrativeOutputTarget.appendChild(entry)
    this.scrollToBottom()
  }

  renderClickableContent(content, clickables) {
    let html = this.escapeHtml(content)

    clickables.forEach(clickable => {
      const pattern = new RegExp(`\\[${this.escapeRegex(clickable.text)}\\]`, 'g')
      html = html.replace(pattern, `
        <span class="clickable"
              data-type="${clickable.type}"
              data-action-type="${clickable.action}"
              data-target-id="${clickable.id}"
              data-controller="narrative-box"
              data-action="click->narrative-box#handleClick mouseenter->narrative-box#showHint mouseleave->narrative-box#hideHint">
          ${clickable.text}
        </span>
      `)
    })

    return `<p>${html}</p>`
  }

  scrollToBottom() {
    this.narrativeOutputTarget.scrollTop = this.narrativeOutputTarget.scrollHeight
  }

  showLoading() {
    const loading = document.createElement('div')
    loading.className = 'narrative-entry system'
    loading.innerHTML = '<span class="loading"></span>'
    loading.id = 'loading-indicator'
    this.narrativeOutputTarget.appendChild(loading)
    this.scrollToBottom()
  }

  hideLoading() {
    const loading = document.getElementById('loading-indicator')
    if (loading) loading.remove()
  }

  // ========================================
  // WebSocket Message Handlers
  // ========================================

  handleTerminalMessage(data) {
    this.hideLoading()

    switch (data.type) {
      // AI DM response with tool results
      case 'dm_response':
        this.appendNarrative('dm', data.narrative, {
          clickables: data.clickables,
          isHtml: data.is_html
        })

        // Show tool results
        if (data.tool_results && data.tool_results.length > 0) {
          data.tool_results.forEach(result => {
            if (result.queued) {
              this.appendNarrative('system', `Pending approval: ${result.message}`)
            } else if (result.success) {
              this.appendNarrative('system', result.message)
            } else if (result.error) {
              this.appendNarrative('error', result.error)
            }
          })
        }

        // Show suggestions if present
        if (data.suggestions && data.suggestions.length > 0) {
          this.showSuggestions(data.suggestions)
        }

        // Update quick actions
        if (data.quick_actions) {
          this.updateQuickActions(data.quick_actions)
        }

        // Update pending approvals
        if (data.pending_approvals) {
          this.updatePendingApprovals(data.pending_approvals)
        }
        break

      // Pending action needs approval
      case 'pending_action':
        this.pendingApprovals.push(data.action)
        this.updatePendingApprovalsUI()
        this.appendNarrative('system', `Action queued for approval: ${data.action.description}`)
        break

      // Action was approved
      case 'action_approved':
        this.removePendingApproval(data.action_id)
        this.appendNarrative('dm', data.follow_up)
        if (data.result && data.result.message) {
          this.appendNarrative('system', data.result.message)
        }
        break

      // Action was rejected
      case 'action_rejected':
        this.removePendingApproval(data.action_id)
        this.appendNarrative('dm', data.follow_up)
        break

      // Pending approvals list updated
      case 'pending_approvals_updated':
        this.pendingApprovals = data.approvals
        this.updatePendingApprovalsUI()
        break

      // State change from tool execution
      case 'state_change':
        if (data.result && data.result.message) {
          this.appendNarrative('system', `[${data.tool_name}] ${data.result.message}`)
        }
        // Show suggestions if present
        if (data.result && data.result.suggestions && data.result.suggestions.length > 0) {
          this.showSuggestions(data.result.suggestions)
        }
        break

      // Dice roll result
      case 'dice_roll':
        if (data.result && data.result.success !== undefined) {
          const rollMsg = `${data.result.message}${data.result.dc ? ` (DC ${data.result.dc}: ${data.result.success ? 'Success!' : 'Failure'})` : ''}`
          this.appendNarrative('roll', rollMsg)
        } else if (data.result) {
          this.appendNarrative('roll', data.result.message)
        }
        break

      // Direct action result
      case 'action_result':
        if (data.result.success) {
          this.appendNarrative('system', data.result.message)
        } else {
          this.appendNarrative('error', data.result.error || 'Action failed')
        }
        break

      // Game state with character sheet
      case 'game_state':
        if (data.character) {
          this.showCharacterSheet(data)
        }
        break

      // Instant message (preprocessed response)
      case 'instant_message':
        this.appendNarrative('system', data.content)
        break

      // Warning message (soft block)
      case 'warning':
        this.appendNarrative('warning', data.message)
        break

      // Mode changed
      case 'mode_changed':
        this.appendNarrative('system', `Mode changed to: ${data.mode}`)
        break

      // Game state response
      case 'game_state':
        if (data.character) {
          this.updateCharacterStatus(data.character)
        }
        if (data.pending_approvals) {
          this.pendingApprovals = data.pending_approvals
          this.updatePendingApprovalsUI()
        }
        break

      // Connected notification
      case 'connected':
        if (data.pending_approvals && data.pending_approvals.length > 0) {
          this.pendingApprovals = data.pending_approvals
          this.updatePendingApprovalsUI()
        }
        break

      // Legacy message types for backwards compatibility
      case 'narrative':
        this.appendNarrative(data.entry_type || 'dm', data.text, {
          clickables: data.clickables
        })
        if (data.quick_actions) {
          this.updateQuickActions(data.quick_actions)
        }
        break

      case 'roll_result':
        this.appendNarrative('roll', this.formatRollResult(data))
        break

      case 'error':
        this.appendNarrative('error', data.message)
        break

      case 'system':
        this.appendNarrative('system', data.message)
        break

      case 'quick_actions_update':
        this.updateQuickActions(data.actions)
        break

      case 'character_update':
        this.updateCharacterStatus(data.character)
        break

      case 'map_generated':
        this.mapIdValue = data.map_id
        this.subscribeToMap(data.map_id)
        this.appendNarrative('system', `Map generated: ${data.name}`)
        break
    }
  }

  // ========================================
  // Pending Approvals
  // ========================================

  updatePendingApprovals(approvals) {
    this.pendingApprovals = approvals
    this.updatePendingApprovalsUI()
  }

  updatePendingApprovalsUI() {
    if (!this.hasPendingActionsTarget) return

    if (this.pendingApprovals.length === 0) {
      this.pendingActionsTarget.innerHTML = ''
      this.pendingActionsTarget.style.display = 'none'
      return
    }

    this.pendingActionsTarget.style.display = 'block'
    this.pendingActionsTarget.innerHTML = `
      <div class="pending-header">Pending Approvals (${this.pendingApprovals.length})</div>
      ${this.pendingApprovals.map(action => `
        <div class="pending-action" data-action-id="${action.id}">
          <div class="pending-description">${action.description}</div>
          ${action.dm_reasoning ? `<div class="pending-reason">${action.dm_reasoning}</div>` : ''}
          <div class="pending-buttons">
            <button class="approve-btn" data-action="click->terminal#approveAction" data-action-id="${action.id}">
              Approve
            </button>
            <button class="reject-btn" data-action="click->terminal#rejectAction" data-action-id="${action.id}">
              Reject
            </button>
          </div>
        </div>
      `).join('')}
    `
  }

  approveAction(event) {
    const actionId = event.currentTarget.dataset.actionId
    this.terminalChannel.perform('approve_action', { action_id: parseInt(actionId) })
  }

  rejectAction(event) {
    const actionId = event.currentTarget.dataset.actionId
    const reason = prompt('Reason for rejection (optional):')
    this.terminalChannel.perform('reject_action', {
      action_id: parseInt(actionId),
      reason: reason
    })
  }

  removePendingApproval(actionId) {
    this.pendingApprovals = this.pendingApprovals.filter(a => a.id !== actionId)
    this.updatePendingApprovalsUI()
  }

  handleMapMessage(data) {
    switch (data.type) {
      case 'initial_state':
      case 'map_update':
        this.updateMapDisplay(data)
        break

      case 'movement':
        this.updatePartyPosition(data.position)
        break

      case 'room_entry':
        this.appendNarrative('dm', data.description, {
          clickables: data.clickables
        })
        if (data.events) {
          data.events.forEach(event => {
            this.appendNarrative('system', event.message)
          })
        }
        break

      case 'export_ready':
        this.appendNarrative('system', `Map exported: ${data.filename}`)
        // Could trigger download here
        break

      case 'render_mode_changed':
        // Request updated map render
        break
    }
  }

  updateMapDisplay(data) {
    if (this.hasMapAsciiTarget && data.ascii) {
      this.mapAsciiTarget.textContent = data.ascii
    }

    // Update canvas if in graphical mode
    if (this.hasMapCanvasTarget && data.tiles) {
      this.renderMapCanvas(data.tiles, data.party_position)
    }
  }

  updatePartyPosition(position) {
    // Update map display with new position
    if (this.mapChannel) {
      // Request refresh
    }
  }

  subscribeToMap(mapId) {
    if (this.mapChannel) this.mapChannel.unsubscribe()

    this.mapChannel = this.consumer.subscriptions.create(
      { channel: "MapChannel", map_id: mapId },
      {
        received: (data) => this.handleMapMessage(data)
      }
    )

    // Show map panel
    if (this.hasMapPanelTarget) {
      this.mapPanelTarget.classList.remove('hidden')
    }
  }

  // ========================================
  // Commands Implementation
  // ========================================

  showHelp() {
    const help = `
Available Commands:
  /help           - Show this help message
  /create         - Create a new character
  /load [name]    - Load a character
  /roll [expr]    - Roll dice (e.g., /roll 2d6+3)
  /inventory      - Show inventory
  /character      - Show character sheet
  /rest [type]    - Take a rest (short/long)
  /map [cmd]      - Map commands (generate, toggle, fog, export)
  /save           - Save current game
  /quit           - Exit game

Quick Actions:
  Press 1-9 to use quick actions
  Ctrl+M to toggle map

Click highlighted text in the narrative to interact with objects and NPCs.
    `.trim()

    this.appendNarrative('system', help)
  }

  rollDice(expression) {
    if (!expression) {
      this.appendNarrative('system', 'Usage: /roll [expression], e.g., /roll 2d6+3')
      return
    }

    this.terminalChannel.perform('roll_dice', {
      dice: expression,
      purpose: 'Manual roll'
    })
  }

  formatRollResult(data) {
    return `Roll: ${data.expression} = ${data.total}
    [${data.rolls.join(', ')}]${data.modifier ? ` + ${data.modifier}` : ''}`
  }

  showInventory() {
    this.terminalChannel.perform('show_inventory')
  }

  showCharacter() {
    this.terminalChannel.perform('show_character')
  }

  rest(type = 'short') {
    this.terminalChannel.perform('rest', { type: type })
  }

  startCharacterCreation() {
    this.terminalChannel.perform('start_character_creation')
  }

  loadCharacter(name) {
    this.terminalChannel.perform('load_character', { name: name })
  }

  saveGame() {
    this.terminalChannel.perform('save_game')
  }

  quitGame() {
    if (confirm('Are you sure you want to quit? Your progress will be saved.')) {
      this.terminalChannel.perform('quit_game')
    }
  }

  // ========================================
  // UI Helpers
  // ========================================

  showTooltip(content, x, y) {
    this.tooltipTarget.innerHTML = content
    this.tooltipTarget.style.left = `${x}px`
    this.tooltipTarget.style.top = `${y}px`
    this.tooltipTarget.style.display = 'block'
  }

  hideTooltip() {
    this.tooltipTarget.style.display = 'none'
  }

  showContextMenu(items, x, y) {
    this.contextMenuTarget.innerHTML = items.map(item => {
      if (item.divider) {
        return '<div class="context-menu-divider"></div>'
      }
      return `
        <div class="context-menu-item"
             data-action="click->terminal#contextMenuAction"
             data-menu-action="${item.action}"
             data-params='${JSON.stringify(item.params || {})}'>
          ${item.label}
        </div>
      `
    }).join('')

    this.contextMenuTarget.style.left = `${x}px`
    this.contextMenuTarget.style.top = `${y}px`
    this.contextMenuTarget.style.display = 'block'
  }

  hideContextMenu() {
    this.contextMenuTarget.style.display = 'none'
  }

  contextMenuAction(event) {
    const action = event.currentTarget.dataset.menuAction
    const params = JSON.parse(event.currentTarget.dataset.params || '{}')

    this.terminalChannel.perform(action, params)
    this.hideContextMenu()
  }

  updateCharacterStatus(character) {
    // Update status bar with new character info
    // This would update HP, conditions, etc.
  }

  startClock() {
    this.clockInterval = setInterval(() => {
      if (this.hasClockTarget) {
        this.clockTarget.textContent = new Date().toLocaleTimeString('en-US', {
          hour: '2-digit',
          minute: '2-digit'
        })
      }
    }, 60000)
  }

  // ========================================
  // Suggestions
  // ========================================

  showSuggestions(suggestions) {
    // Get the suggestions controller
    const suggestionsController = this.application.getControllerForElementAndIdentifier(
      this.suggestionsPanelTarget,
      "suggestions"
    )

    if (suggestionsController) {
      suggestionsController.showSuggestions(suggestions)
    }
  }

  // ========================================
  // Utility Methods
  // ========================================

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  }
}
