import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "batchButton", "customInput"]

  connect() {
    this.selectedSuggestions = new Set()
    console.log("Suggestions controller connected")
  }

  // Display suggestions (called from terminal controller when tool results arrive)
  showSuggestions(suggestions) {
    if (!suggestions || suggestions.length === 0) {
      this.hide()
      return
    }

    this.contentTarget.innerHTML = ""
    this.selectedSuggestions.clear()

    suggestions.forEach((suggestion, index) => {
      const item = this.createSuggestionItem(suggestion, index)
      this.contentTarget.appendChild(item)
    })

    this.element.style.display = "block"
    this.updateBatchButton()
  }

  createSuggestionItem(suggestion, index) {
    const div = document.createElement("div")
    div.className = "suggestion-item"
    div.dataset.suggestionIndex = index
    div.dataset.action = "click->suggestions#toggleSelection"

    const headerRow = document.createElement("div")
    headerRow.className = "suggestion-header-row"

    const icon = document.createElement("span")
    icon.className = "suggestion-icon"
    icon.textContent = suggestion.icon

    const action = document.createElement("span")
    action.className = "suggestion-action"
    action.textContent = suggestion.action

    const checkbox = document.createElement("input")
    checkbox.type = "checkbox"
    checkbox.className = "suggestion-checkbox"
    checkbox.dataset.action = "click->suggestions#handleCheckboxClick"
    checkbox.dataset.suggestionIndex = index

    headerRow.appendChild(icon)
    headerRow.appendChild(action)
    headerRow.appendChild(checkbox)
    div.appendChild(headerRow)

    if (suggestion.examples && suggestion.examples.length > 0) {
      const examples = document.createElement("div")
      examples.className = "suggestion-examples"

      const exampleLinks = suggestion.examples.slice(0, 2).map((example, exIdx) => {
        const link = document.createElement("span")
        link.className = "suggestion-example-link"
        link.textContent = `"${example}"`
        link.dataset.action = "click->suggestions#executeExample"
        link.dataset.example = example
        return link
      })

      examples.appendChild(document.createTextNode("Try: "))
      exampleLinks.forEach((link, idx) => {
        examples.appendChild(link)
        if (idx < exampleLinks.length - 1) {
          examples.appendChild(document.createTextNode(" or "))
        }
      })

      div.appendChild(examples)
    }

    // Store suggestion data
    div.dataset.suggestion = JSON.stringify(suggestion)

    return div
  }

  toggleSelection(event) {
    // Prevent checkbox clicks from bubbling
    if (event.target.classList.contains("suggestion-checkbox")) {
      return
    }

    // Prevent example link clicks from bubbling
    if (event.target.classList.contains("suggestion-example-link")) {
      return
    }

    const item = event.currentTarget
    const index = item.dataset.suggestionIndex
    const checkbox = item.querySelector(".suggestion-checkbox")

    if (this.selectedSuggestions.has(index)) {
      this.selectedSuggestions.delete(index)
      item.classList.remove("selected")
      checkbox.checked = false
    } else {
      this.selectedSuggestions.add(index)
      item.classList.add("selected")
      checkbox.checked = true
    }

    this.updateBatchButton()
  }

  handleCheckboxClick(event) {
    event.stopPropagation()
    const checkbox = event.target
    const index = checkbox.dataset.suggestionIndex
    const item = checkbox.closest(".suggestion-item")

    if (checkbox.checked) {
      this.selectedSuggestions.add(index)
      item.classList.add("selected")
    } else {
      this.selectedSuggestions.delete(index)
      item.classList.remove("selected")
    }

    this.updateBatchButton()
  }

  updateBatchButton() {
    if (this.selectedSuggestions.size > 0) {
      this.batchButtonTarget.style.display = "block"
      this.batchButtonTarget.textContent = `Execute ${this.selectedSuggestions.size} Selected Action${this.selectedSuggestions.size > 1 ? 's' : ''}`
    } else {
      this.batchButtonTarget.style.display = "none"
    }
  }

  executeExample(event) {
    event.stopPropagation()
    const example = event.target.dataset.example

    // Send to terminal input
    const terminalController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="terminal"]'),
      "terminal"
    )

    if (terminalController) {
      terminalController.inputTarget.value = example
      terminalController.sendMessage()
      this.hide()
    }
  }

  executeSelectedBatch() {
    const selectedItems = Array.from(this.selectedSuggestions).map(index => {
      const item = this.contentTarget.querySelector(`[data-suggestion-index="${index}"]`)
      return JSON.parse(item.dataset.suggestion)
    })

    if (selectedItems.length === 0) return

    // Get the first example from each selected suggestion
    const commands = selectedItems.map(suggestion => {
      return suggestion.examples && suggestion.examples.length > 0
        ? suggestion.examples[0]
        : suggestion.action
    })

    // Send batch commands to terminal
    const terminalController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="terminal"]'),
      "terminal"
    )

    if (terminalController) {
      // Execute commands sequentially with small delay
      commands.forEach((command, index) => {
        setTimeout(() => {
          terminalController.inputTarget.value = command
          terminalController.sendMessage()

          // Hide suggestions after last command
          if (index === commands.length - 1) {
            setTimeout(() => this.hide(), 500)
          }
        }, index * 1000) // 1 second between each command
      })
    }
  }

  handleCustomInput(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      const customCommand = this.customInputTarget.value.trim()

      if (customCommand) {
        const terminalController = this.application.getControllerForElementAndIdentifier(
          document.querySelector('[data-controller="terminal"]'),
          "terminal"
        )

        if (terminalController) {
          terminalController.inputTarget.value = customCommand
          terminalController.sendMessage()
          this.customInputTarget.value = ""
          this.hide()
        }
      }
    } else if (event.key === "Escape") {
      this.close()
    }
  }

  close() {
    this.hide()
  }

  hide() {
    this.element.style.display = "none"
    this.selectedSuggestions.clear()
    this.contentTarget.innerHTML = ""
    this.customInputTarget.value = ""
  }
}
