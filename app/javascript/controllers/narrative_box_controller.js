import { Controller } from "@hotwired/stimulus"

// Handles clickable elements in narrative text and memory hint tooltips
export default class extends Controller {
  static targets = ["entry"]

  connect() {
    // Attach event listeners to clickable elements
    this.element.querySelectorAll('.clickable').forEach(el => {
      el.addEventListener('click', this.handleClick.bind(this))
      el.addEventListener('mouseenter', this.showHint.bind(this))
      el.addEventListener('mouseleave', this.hideHint.bind(this))
      el.addEventListener('contextmenu', this.showContextMenu.bind(this))
    })
  }

  // Handle click on interactive element
  handleClick(event) {
    const element = event.currentTarget
    const type = element.dataset.type
    const actionType = element.dataset.actionType
    const targetId = element.dataset.targetId

    // Get terminal controller
    const terminalController = this.getTerminalController()
    if (!terminalController) return

    // Determine action based on element type
    switch (type) {
      case 'object':
        this.interactWithObject(terminalController, targetId, actionType)
        break
      case 'npc':
        this.interactWithNpc(terminalController, targetId, actionType)
        break
      case 'location':
        this.travelToLocation(terminalController, targetId)
        break
      case 'item':
        this.examineItem(terminalController, targetId)
        break
      default:
        // Default interaction
        terminalController.terminalChannel.perform('interact', {
          element_type: type,
          target_id: targetId,
          action: actionType || 'examine'
        })
    }
  }

  // Show memory hint tooltip on hover
  showHint(event) {
    const element = event.currentTarget
    const targetId = element.dataset.targetId
    const type = element.dataset.type

    // Request hint from server or use cached
    const hint = this.getMemoryHint(type, targetId)
    if (!hint) return

    const terminalController = this.getTerminalController()
    if (!terminalController) return

    const rect = element.getBoundingClientRect()
    const content = `
      <div>${hint.text}</div>
      ${hint.source ? `<div class="hint-source">From: ${hint.source}</div>` : ''}
    `

    terminalController.showTooltip(content, rect.left, rect.bottom + 5)
  }

  // Hide tooltip
  hideHint(event) {
    const terminalController = this.getTerminalController()
    if (terminalController) {
      terminalController.hideTooltip()
    }
  }

  // Show context menu with interaction options
  showContextMenu(event) {
    event.preventDefault()

    const element = event.currentTarget
    const type = element.dataset.type
    const targetId = element.dataset.targetId

    const terminalController = this.getTerminalController()
    if (!terminalController) return

    // Build menu items based on type
    const items = this.getContextMenuItems(type, targetId)

    terminalController.showContextMenu(items, event.clientX, event.clientY)
  }

  // Get context menu items for element type
  getContextMenuItems(type, targetId) {
    switch (type) {
      case 'object':
        return [
          { label: 'Examine', action: 'interact', params: { element_type: type, target_id: targetId, action: 'examine' } },
          { label: 'Investigate', action: 'interact', params: { element_type: type, target_id: targetId, action: 'investigate' } },
          { label: 'Search', action: 'interact', params: { element_type: type, target_id: targetId, action: 'search' } },
          { divider: true },
          { label: 'Use', action: 'interact', params: { element_type: type, target_id: targetId, action: 'use' } }
        ]

      case 'npc':
        return [
          { label: 'Talk', action: 'interact', params: { element_type: type, target_id: targetId, action: 'talk' } },
          { label: 'Examine', action: 'interact', params: { element_type: type, target_id: targetId, action: 'examine' } },
          { divider: true },
          { label: 'Attack', action: 'interact', params: { element_type: type, target_id: targetId, action: 'attack' } }
        ]

      case 'location':
        return [
          { label: 'Travel', action: 'interact', params: { element_type: type, target_id: targetId, action: 'travel' } },
          { label: 'Examine', action: 'interact', params: { element_type: type, target_id: targetId, action: 'examine' } }
        ]

      case 'item':
        return [
          { label: 'Examine', action: 'interact', params: { element_type: type, target_id: targetId, action: 'examine' } },
          { label: 'Take', action: 'interact', params: { element_type: type, target_id: targetId, action: 'take' } },
          { divider: true },
          { label: 'Use', action: 'interact', params: { element_type: type, target_id: targetId, action: 'use' } }
        ]

      default:
        return [
          { label: 'Examine', action: 'interact', params: { element_type: type, target_id: targetId, action: 'examine' } }
        ]
    }
  }

  // Interaction methods
  interactWithObject(controller, targetId, action) {
    controller.terminalChannel.perform('interact', {
      element_type: 'object',
      target_id: targetId,
      action: action || 'investigate'
    })
  }

  interactWithNpc(controller, targetId, action) {
    controller.terminalChannel.perform('interact', {
      element_type: 'npc',
      target_id: targetId,
      action: action || 'talk'
    })
  }

  travelToLocation(controller, targetId) {
    controller.terminalChannel.perform('travel', {
      location_id: targetId
    })
  }

  examineItem(controller, targetId) {
    controller.terminalChannel.perform('interact', {
      element_type: 'item',
      target_id: targetId,
      action: 'examine'
    })
  }

  // Get memory hint for element
  getMemoryHint(type, targetId) {
    // In a real implementation, this would query cached memory or fetch from server
    // For now, return placeholder hints based on type
    const hints = {
      object: {
        text: 'You remember seeing something like this before...',
        source: 'Memory'
      },
      npc: {
        text: 'This person seems familiar.',
        source: 'Character knowledge'
      },
      location: {
        text: 'You have heard of this place.',
        source: 'World lore'
      },
      item: {
        text: 'You recognize this item.',
        source: 'Inventory memory'
      }
    }

    return hints[type] || null
  }

  // Get terminal controller from parent
  getTerminalController() {
    const terminalElement = document.querySelector('[data-controller="terminal"]')
    if (!terminalElement) return null

    return this.application.getControllerForElementAndIdentifier(
      terminalElement,
      'terminal'
    )
  }
}
