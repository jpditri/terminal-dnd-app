# frozen_string_literal: true

require 'discordrb'

module Discord
  # Discord bot service for AI DM integration
  # Allows players to interact with the AI DM through Discord channels
  class BotService
    attr_reader :bot, :logger

    def initialize
      @logger = Rails.logger
      @bot = create_bot
      @active_sessions = {}
      register_handlers
    end

    def start
      logger.info '[Discord] Starting bot...'
      bot.run(true) # Run asynchronously
    end

    def stop
      logger.info '[Discord] Stopping bot...'
      bot.stop
    end

    private

    def create_bot
      Discordrb::Commands::CommandBot.new(
        token: Rails.application.credentials.dig(:discord, :bot_token),
        client_id: Rails.application.credentials.dig(:discord, :client_id),
        prefix: '!dnd ',
        help_command: false
      )
    end

    def register_handlers
      register_commands
      register_message_handler
      register_reaction_handlers
    end

    def register_commands
      # Start a new game session
      bot.command(:start, description: 'Start a new D&D adventure') do |event|
        handle_start_command(event)
      end

      # Join existing session
      bot.command(:join, description: 'Join an existing game session') do |event, session_code|
        handle_join_command(event, session_code)
      end

      # End current session
      bot.command(:end, description: 'End your current game session') do |event|
        handle_end_command(event)
      end

      # Create character
      bot.command(:create, description: 'Create a new character') do |event, *args|
        handle_create_command(event, args)
      end

      # Roll dice
      bot.command(:roll, description: 'Roll dice (e.g., !dnd roll 2d6+3)') do |event, *dice_expr|
        handle_roll_command(event, dice_expr.join(' '))
      end

      # Show character stats
      bot.command(:stats, description: 'Show your character stats') do |event|
        handle_stats_command(event)
      end

      # Show inventory
      bot.command(:inventory, description: 'Show your inventory') do |event|
        handle_inventory_command(event)
      end

      # Help command
      bot.command(:help, description: 'Show available commands') do |event|
        handle_help_command(event)
      end

      # Approve pending action
      bot.command(:approve, description: 'Approve a pending DM action') do |event, action_id|
        handle_approve_command(event, action_id)
      end

      # Reject pending action
      bot.command(:reject, description: 'Reject a pending DM action') do |event, action_id|
        handle_reject_command(event, action_id)
      end
    end

    def register_message_handler
      bot.message do |event|
        # Skip if message starts with command prefix
        next if event.message.content.start_with?('!dnd ')

        # Only process in active game channels
        session = find_session_for_channel(event.channel.id)
        next unless session

        # Process as player input to AI DM
        handle_player_message(event, session)
      end
    end

    def register_reaction_handlers
      # Quick approve/reject via reactions
      bot.reaction_add do |event|
        handle_reaction(event)
      end
    end

    # Command Handlers

    def handle_start_command(event)
      user = find_or_create_user(event.user)

      # Check for existing active session
      existing = user.terminal_sessions.where(active: true).first
      if existing
        return event.respond "You already have an active session! Use `!dnd end` to end it first."
      end

      # Create new session
      session = TerminalSession.create!(
        user: user,
        title: "Discord Adventure - #{event.channel.name}",
        mode: 'exploration',
        active: true,
        discord_channel_id: event.channel.id.to_s
      )

      @active_sessions[event.channel.id] = session.id

      embed = Discordrb::Webhooks::Embed.new(
        title: '🎲 Adventure Begins!',
        description: "Welcome to Terminal D&D!\n\nSession Code: `#{session.id}`\n\nType anything to interact with the AI Dungeon Master, or use commands:\n• `!dnd create` - Create a character\n• `!dnd roll 1d20` - Roll dice\n• `!dnd help` - Show all commands",
        color: 0x7C3AED
      )

      event.channel.send_embed('', embed)
    end

    def handle_join_command(event, session_code)
      return event.respond "Please provide a session code: `!dnd join <code>`" if session_code.blank?

      session = TerminalSession.find_by(id: session_code, active: true)
      return event.respond "Session not found or inactive." unless session

      user = find_or_create_user(event.user)
      @active_sessions[event.channel.id] = session.id

      event.respond "✅ Joined session: **#{session.title}**"
    end

    def handle_end_command(event)
      session = find_session_for_channel(event.channel.id)
      return event.respond "No active session in this channel." unless session

      session.update!(active: false)
      @active_sessions.delete(event.channel.id)

      event.respond "🏁 Adventure ended! Thanks for playing."
    end

    def handle_create_command(event, args)
      session = find_session_for_channel(event.channel.id)
      return event.respond "Start a game first with `!dnd start`" unless session

      user = find_or_create_user(event.user)
      orchestrator = AiDm::Orchestrator.new(session)

      # Parse character creation args or start interactive creation
      if args.empty?
        response = orchestrator.process_message("I want to create a new character", [])
      else
        name = args.first
        response = orchestrator.process_message("Create a character named #{name}", [])
      end

      send_dm_response(event.channel, response)
    end

    def handle_roll_command(event, dice_expr)
      return event.respond "Usage: `!dnd roll 2d6+3`" if dice_expr.blank?

      result = DiceRoller.roll(dice_expr)

      embed = Discordrb::Webhooks::Embed.new(
        title: "🎲 #{dice_expr}",
        description: "**Result: #{result[:total]}**\n\nRolls: #{result[:rolls].join(', ')}#{result[:modifier] != 0 ? " (#{result[:modifier] >= 0 ? '+' : ''}#{result[:modifier]})" : ''}",
        color: result[:critical] ? 0xFFD700 : 0x3B82F6
      )

      event.channel.send_embed('', embed)
    rescue StandardError => e
      event.respond "Invalid dice expression: #{e.message}"
    end

    def handle_stats_command(event)
      session = find_session_for_channel(event.channel.id)
      return event.respond "Start a game first with `!dnd start`" unless session

      character = session.character
      return event.respond "No character in this session. Use `!dnd create` to make one." unless character

      embed = build_character_embed(character)
      event.channel.send_embed('', embed)
    end

    def handle_inventory_command(event)
      session = find_session_for_channel(event.channel.id)
      return event.respond "Start a game first with `!dnd start`" unless session

      character = session.character
      return event.respond "No character found." unless character

      items = character.inventory_items.includes(:item)
      if items.empty?
        event.respond "Your inventory is empty."
      else
        item_list = items.map { |ii| "• #{ii.item.name} (x#{ii.quantity})" }.join("\n")
        embed = Discordrb::Webhooks::Embed.new(
          title: "🎒 #{character.name}'s Inventory",
          description: item_list,
          color: 0x8B4513
        )
        event.channel.send_embed('', embed)
      end
    end

    def handle_help_command(event)
      commands = [
        '**Game Session**',
        '`!dnd start` - Start a new adventure',
        '`!dnd join <code>` - Join existing session',
        '`!dnd end` - End current session',
        '',
        '**Character**',
        '`!dnd create [name]` - Create character',
        '`!dnd stats` - View character stats',
        '`!dnd inventory` - View inventory',
        '',
        '**Gameplay**',
        '`!dnd roll <dice>` - Roll dice (e.g., 2d6+3)',
        '`!dnd approve <id>` - Approve DM action',
        '`!dnd reject <id>` - Reject DM action',
        '',
        '**Tips**',
        'Just type normally to talk to the AI DM!',
        'React with ✅ or ❌ to approve/reject actions'
      ]

      embed = Discordrb::Webhooks::Embed.new(
        title: '📜 Terminal D&D Commands',
        description: commands.join("\n"),
        color: 0x7C3AED
      )

      event.channel.send_embed('', embed)
    end

    def handle_approve_command(event, action_id)
      return event.respond "Usage: `!dnd approve <action_id>`" if action_id.blank?

      user = find_or_create_user(event.user)
      action = DmPendingAction.find_by(id: action_id, status: 'pending')

      return event.respond "Action not found or already processed." unless action

      result = action.approve!(reviewer: user)

      if result[:success]
        event.respond "✅ Action approved: #{action.description}"
      else
        event.respond "❌ Action failed: #{result[:error]}"
      end
    end

    def handle_reject_command(event, action_id)
      return event.respond "Usage: `!dnd reject <action_id>`" if action_id.blank?

      user = find_or_create_user(event.user)
      action = DmPendingAction.find_by(id: action_id, status: 'pending')

      return event.respond "Action not found or already processed." unless action

      action.reject!(reviewer: user)
      event.respond "❌ Action rejected: #{action.description}"
    end

    # Message Handler

    def handle_player_message(event, session)
      user = find_or_create_user(event.user)

      # Show typing indicator
      event.channel.start_typing

      orchestrator = AiDm::Orchestrator.new(session)
      history = build_discord_history(event.channel, limit: 10)

      response = orchestrator.process_message(event.message.content, history)
      send_dm_response(event.channel, response)
    end

    def handle_reaction(event)
      # Only handle reactions on bot messages
      return unless event.message.author.id == bot.profile.id

      case event.emoji.name
      when '✅'
        # Find pending action from message
        action_id = extract_action_id(event.message.content)
        return unless action_id

        user = find_or_create_user(event.user)
        action = DmPendingAction.find_by(id: action_id, status: 'pending')
        action&.approve!(reviewer: user)
      when '❌'
        action_id = extract_action_id(event.message.content)
        return unless action_id

        user = find_or_create_user(event.user)
        action = DmPendingAction.find_by(id: action_id, status: 'pending')
        action&.reject!(reviewer: user)
      end
    end

    # Helper Methods

    def find_or_create_user(discord_user)
      User.find_by(discord_id: discord_user.id.to_s) || User.create!(
        email: "discord_#{discord_user.id}@terminal-dnd.local",
        password: SecureRandom.hex(16),
        discord_id: discord_user.id.to_s,
        discord_username: discord_user.username,
        discord_discriminator: discord_user.discriminator,
        discord_avatar: discord_user.avatar_url
      )
    end

    def find_session_for_channel(channel_id)
      session_id = @active_sessions[channel_id]
      return TerminalSession.find_by(id: session_id) if session_id

      # Try to find by discord_channel_id
      TerminalSession.find_by(discord_channel_id: channel_id.to_s, active: true)
    end

    def send_dm_response(channel, response)
      # Main narrative
      if response[:narrative].present?
        # Split long messages
        chunks = response[:narrative].scan(/.{1,1900}/m)
        chunks.each { |chunk| channel.send_message(chunk) }
      end

      # Tool results as embeds
      response[:tool_results]&.each do |result|
        next unless result[:success]

        embed = Discordrb::Webhooks::Embed.new(
          title: "⚙️ #{result[:tool].to_s.humanize}",
          description: result[:message],
          color: 0x22C55E
        )
        channel.send_embed('', embed)
      end

      # Pending approvals
      response[:pending_approvals]&.each do |approval|
        embed = Discordrb::Webhooks::Embed.new(
          title: '⚠️ Approval Required',
          description: "#{approval[:description]}\n\n**Reason:** #{approval[:reason]}\n\n`!dnd approve #{approval[:id]}` or `!dnd reject #{approval[:id]}`\n\nOr react with ✅ / ❌",
          color: 0xF59E0B
        )
        msg = channel.send_embed('', embed)
        msg.react('✅')
        msg.react('❌')
      end
    end

    def build_character_embed(character)
      stats = "STR: #{character.strength} | DEX: #{character.dexterity} | CON: #{character.constitution}\n" \
              "INT: #{character.intelligence} | WIS: #{character.wisdom} | CHA: #{character.charisma}"

      Discordrb::Webhooks::Embed.new(
        title: "⚔️ #{character.name}",
        description: "Level #{character.level} #{character.race&.name} #{character.character_class&.name}",
        color: 0x7C3AED,
        fields: [
          { name: 'HP', value: "#{character.current_hp}/#{character.max_hp}", inline: true },
          { name: 'AC', value: character.armor_class.to_s, inline: true },
          { name: 'Initiative', value: "+#{character.initiative_bonus}", inline: true },
          { name: 'Ability Scores', value: stats, inline: false }
        ]
      )
    end

    def build_discord_history(channel, limit: 10)
      messages = channel.history(limit)
      messages.reverse.map do |msg|
        {
          role: msg.author.id == bot.profile.id ? 'assistant' : 'user',
          content: msg.content
        }
      end
    end

    def extract_action_id(content)
      match = content.match(/approve\s+(\d+)|reject\s+(\d+)|Action ID:\s*(\d+)/i)
      match&.captures&.compact&.first
    end
  end

  # Simple dice roller utility
  class DiceRoller
    def self.roll(expression)
      # Parse expression like "2d6+3"
      match = expression.match(/(\d+)d(\d+)([+-]\d+)?/i)
      raise "Invalid dice expression" unless match

      num_dice = match[1].to_i
      die_size = match[2].to_i
      modifier = match[3].to_i

      rolls = num_dice.times.map { rand(1..die_size) }
      total = rolls.sum + modifier

      {
        rolls: rolls,
        modifier: modifier,
        total: total,
        critical: rolls.include?(die_size) && die_size == 20
      }
    end
  end
end
