import { Controller } from "@hotwired/stimulus"

// Handles canvas-based map rendering for both SVG and Sprite modes
export default class extends Controller {
  static targets = ["canvas", "container"]

  static values = {
    mode: { type: String, default: "svg" },  // "svg" or "sprite"
    tileSize: { type: Number, default: 16 },
    mapId: Number
  }

  connect() {
    this.ctx = this.canvasTarget.getContext('2d')
    this.tileset = null
    this.tilesetLoaded = false
    this.mapData = null

    // Load tileset for sprite mode
    if (this.modeValue === 'sprite') {
      this.loadTileset()
    }

    // Handle window resize
    window.addEventListener('resize', this.handleResize.bind(this))
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize.bind(this))
  }

  // Load tileset image
  loadTileset() {
    this.tileset = new Image()
    this.tileset.onload = () => {
      this.tilesetLoaded = true
      if (this.mapData) {
        this.render(this.mapData)
      }
    }
    this.tileset.onerror = () => {
      console.error('Failed to load tileset')
    }
    this.tileset.src = '/assets/tilesets/dungeon.png'
  }

  // Main render method - called when map data is received
  render(data) {
    this.mapData = data

    // Set canvas size
    const width = data.width * this.tileSizeValue
    const height = data.height * this.tileSizeValue
    this.canvasTarget.width = width
    this.canvasTarget.height = height

    // Clear canvas
    this.ctx.fillStyle = '#000'
    this.ctx.fillRect(0, 0, width, height)

    if (this.modeValue === 'sprite' && this.tilesetLoaded) {
      this.renderSprites(data)
    } else if (this.modeValue === 'svg') {
      this.renderSvgStyle(data)
    }

    // Render entities
    this.renderEntities(data.entities)

    // Render party
    if (data.party) {
      this.renderParty(data.party)
    }
  }

  // Render using sprite tileset
  renderSprites(data) {
    const tileSize = this.tileSizeValue
    const spriteSize = data.sprite_size || 16

    data.tiles.forEach(tile => {
      const destX = tile.x * tileSize
      const destY = tile.y * tileSize

      // Get sprite coordinates
      const sprite = tile.sprite
      const srcX = sprite.col * spriteSize
      const srcY = sprite.row * spriteSize

      // Draw tile
      this.ctx.drawImage(
        this.tileset,
        srcX, srcY, spriteSize, spriteSize,
        destX, destY, tileSize, tileSize
      )

      // Apply fog overlay
      if (tile.visibility === 'dim') {
        this.ctx.fillStyle = 'rgba(0, 0, 0, 0.5)'
        this.ctx.fillRect(destX, destY, tileSize, tileSize)
      }
    })
  }

  // Render using simple colored rectangles (SVG-like)
  renderSvgStyle(data) {
    const tileSize = this.tileSizeValue

    const colors = {
      'floor': '#8B7355',
      'wall': '#4a4a4a',
      'door': '#8B4513',
      'door_open': '#D2691E',
      'door_locked': '#4a0000',
      'stairs_up': '#666666',
      'stairs_down': '#666666',
      'trap': '#ff4444',
      'chest': '#FFD700',
      'water': '#4169E1',
      'pit': '#1a1a1a',
      'pillar': '#808080',
      'altar': '#9932CC',
      'statue': '#A9A9A9',
      'empty': '#000000'
    }

    data.tiles.forEach(tile => {
      const x = tile.x * tileSize
      const y = tile.y * tileSize
      const type = this.getTileType(tile)

      // Draw base tile
      this.ctx.fillStyle = colors[type] || colors['floor']
      this.ctx.fillRect(x, y, tileSize, tileSize)

      // Add details based on type
      this.drawTileDetails(tile, x, y, tileSize)

      // Apply fog
      if (tile.visibility === 'dim') {
        this.ctx.fillStyle = 'rgba(0, 0, 0, 0.5)'
        this.ctx.fillRect(x, y, tileSize, tileSize)
      }
    })
  }

  // Get tile type from sprite data
  getTileType(tile) {
    // Reverse lookup from sprite to type
    const spriteToType = {
      '0,0': 'floor',
      '1,0': 'wall',
      '2,0': 'door',
      '2,1': 'door_open',
      '2,2': 'door_locked',
      '3,0': 'stairs_up',
      '3,1': 'stairs_down',
      '3,2': 'trap',
      '4,0': 'chest',
      '4,1': 'chest_open',
      '4,2': 'water',
      '4,3': 'pit',
      '5,0': 'pillar',
      '5,1': 'altar',
      '5,2': 'statue'
    }

    if (tile.sprite) {
      const key = `${tile.sprite.row},${tile.sprite.col}`
      return spriteToType[key] || 'floor'
    }

    return 'floor'
  }

  // Draw additional details for specific tile types
  drawTileDetails(tile, x, y, size) {
    const type = this.getTileType(tile)
    const ctx = this.ctx

    switch (type) {
      case 'wall':
        ctx.strokeStyle = '#333'
        ctx.lineWidth = 1
        ctx.strokeRect(x, y, size, size)
        break

      case 'door':
      case 'door_open':
      case 'door_locked':
        // Door frame
        ctx.fillStyle = '#654321'
        const doorW = size * 0.6
        const doorH = size * 0.8
        ctx.fillRect(x + (size - doorW) / 2, y + (size - doorH) / 2, doorW, doorH)
        break

      case 'stairs_up':
      case 'stairs_down':
        // Draw steps
        ctx.fillStyle = '#888'
        for (let i = 0; i < 3; i++) {
          const stepY = type === 'stairs_up' ? y + size - (i + 1) * (size / 4) : y + i * (size / 4)
          ctx.fillRect(x + 2, stepY, size - 4, size / 5)
        }
        break

      case 'chest':
        // Chest body
        ctx.fillStyle = '#B8860B'
        ctx.fillRect(x + size * 0.2, y + size * 0.4, size * 0.6, size * 0.5)
        break

      case 'water':
        // Wave pattern
        ctx.strokeStyle = '#6495ED'
        ctx.beginPath()
        ctx.moveTo(x + 2, y + size / 2)
        ctx.quadraticCurveTo(x + size / 4, y + size / 3, x + size / 2, y + size / 2)
        ctx.quadraticCurveTo(x + size * 0.75, y + size * 0.67, x + size - 2, y + size / 2)
        ctx.stroke()
        break

      case 'trap':
        // Spike triangle
        ctx.fillStyle = '#ff6666'
        ctx.beginPath()
        ctx.moveTo(x + size / 2, y + 3)
        ctx.lineTo(x + 3, y + size - 3)
        ctx.lineTo(x + size - 3, y + size - 3)
        ctx.closePath()
        ctx.fill()
        break
    }
  }

  // Render entities (enemies, NPCs)
  renderEntities(entities) {
    if (!entities) return

    const tileSize = this.tileSizeValue
    const ctx = this.ctx

    entities.forEach(entity => {
      const x = entity.x * tileSize + tileSize / 2
      const y = entity.y * tileSize + tileSize / 2
      const radius = tileSize / 3

      // Entity colors
      const colors = {
        enemy: '#ff0000',
        boss: '#ff00ff',
        npc: '#00aaff'
      }

      // Draw entity circle
      ctx.fillStyle = colors[entity.type] || '#ffffff'
      ctx.beginPath()
      ctx.arc(x, y, radius, 0, Math.PI * 2)
      ctx.fill()

      // Border
      ctx.strokeStyle = '#ffffff'
      ctx.lineWidth = 1
      ctx.stroke()

      // Label
      ctx.fillStyle = '#ffffff'
      ctx.font = `${tileSize / 2}px monospace`
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      const label = entity.type === 'boss' ? 'B' : entity.type === 'enemy' ? 'E' : 'N'
      ctx.fillText(label, x, y)
    })
  }

  // Render party marker
  renderParty(party) {
    const tileSize = this.tileSizeValue
    const ctx = this.ctx

    const x = party.x * tileSize + tileSize / 2
    const y = party.y * tileSize + tileSize / 2
    const radius = tileSize / 3

    // Glow effect
    ctx.shadowColor = '#00ff00'
    ctx.shadowBlur = 10

    // Party circle
    ctx.fillStyle = '#00ff00'
    ctx.beginPath()
    ctx.arc(x, y, radius, 0, Math.PI * 2)
    ctx.fill()

    // Reset shadow
    ctx.shadowBlur = 0

    // Border
    ctx.strokeStyle = '#ffffff'
    ctx.lineWidth = 2
    ctx.stroke()

    // @ symbol
    ctx.fillStyle = '#000000'
    ctx.font = `bold ${tileSize / 2}px monospace`
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText('@', x, y)
  }

  // Handle click on map
  handleClick(event) {
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = Math.floor((event.clientX - rect.left) / this.tileSizeValue)
    const y = Math.floor((event.clientY - rect.top) / this.tileSizeValue)

    // Dispatch custom event for movement
    this.dispatch('tileClick', { detail: { x, y } })
  }

  // Handle hover for tooltips
  handleMouseMove(event) {
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = Math.floor((event.clientX - rect.left) / this.tileSizeValue)
    const y = Math.floor((event.clientY - rect.top) / this.tileSizeValue)

    // Check for entities at position
    if (this.mapData && this.mapData.entities) {
      const entity = this.mapData.entities.find(e => e.x === x && e.y === y)
      if (entity) {
        this.dispatch('entityHover', { detail: { entity, x: event.clientX, y: event.clientY } })
        return
      }
    }

    this.dispatch('entityHover', { detail: null })
  }

  // Handle window resize
  handleResize() {
    if (this.mapData) {
      this.render(this.mapData)
    }
  }

  // Update party position (animate movement)
  updatePartyPosition(newX, newY, animate = true) {
    if (!this.mapData || !this.mapData.party) return

    if (animate) {
      this.animateMovement(this.mapData.party.x, this.mapData.party.y, newX, newY)
    } else {
      this.mapData.party.x = newX
      this.mapData.party.y = newY
      this.render(this.mapData)
    }
  }

  // Animate party movement
  animateMovement(fromX, fromY, toX, toY) {
    const duration = 200 // ms
    const startTime = performance.now()

    const animate = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)

      // Easing function
      const eased = 1 - Math.pow(1 - progress, 3)

      // Calculate current position
      const currentX = fromX + (toX - fromX) * eased
      const currentY = fromY + (toY - fromY) * eased

      // Update and render
      this.mapData.party.x = currentX
      this.mapData.party.y = currentY
      this.render(this.mapData)

      if (progress < 1) {
        requestAnimationFrame(animate)
      } else {
        // Ensure final position
        this.mapData.party.x = toX
        this.mapData.party.y = toY
      }
    }

    requestAnimationFrame(animate)
  }

  // Set render mode
  setMode(mode) {
    this.modeValue = mode

    if (mode === 'sprite' && !this.tilesetLoaded) {
      this.loadTileset()
    } else if (this.mapData) {
      this.render(this.mapData)
    }
  }

  // Set tile size
  setTileSize(size) {
    this.tileSizeValue = size
    if (this.mapData) {
      this.render(this.mapData)
    }
  }
}
