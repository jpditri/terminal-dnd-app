# frozen_string_literal: true

require 'discordrb/webhooks'

module Discord
  # Service for sending Discord webhook notifications
  # Used for asynchronous game updates and alerts
  class WebhookService
    attr_reader :webhook_url, :client

    def initialize(webhook_url = nil)
      @webhook_url = webhook_url || Rails.application.credentials.dig(:discord, :webhook_url)
      @client = Discordrb::Webhooks::Client.new(url: @webhook_url) if @webhook_url
    end

    # Send a simple message
    def send_message(content, username: 'Terminal D&D', avatar_url: nil)
      return unless client

      client.execute do |builder|
        builder.content = content
        builder.username = username
        builder.avatar_url = avatar_url if avatar_url
      end
    end

    # Send a rich embed message
    def send_embed(title:, description:, color: 0x7C3AED, fields: [], footer: nil, thumbnail: nil)
      return unless client

      client.execute do |builder|
        builder.username = 'Terminal D&D'

        builder.add_embed do |embed|
          embed.title = title
          embed.description = description
          embed.color = color
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: thumbnail) if thumbnail
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer) if footer

          fields.each do |field|
            embed.add_field(
              name: field[:name],
              value: field[:value],
              inline: field[:inline] || false
            )
          end
        end
      end
    end

    # Game event notifications

    def notify_session_started(session, user)
      send_embed(
        title: '🎲 New Adventure Started!',
        description: "**#{user.name}** has begun a new adventure.",
        color: 0x22C55E,
        fields: [
          { name: 'Session', value: session.title, inline: true },
          { name: 'Mode', value: session.mode.humanize, inline: true }
        ]
      )
    end

    def notify_character_created(character)
      send_embed(
        title: '⚔️ New Hero Rises!',
        description: "**#{character.name}** joins the realm.",
        color: 0x7C3AED,
        fields: [
          { name: 'Race', value: character.race&.name || 'Unknown', inline: true },
          { name: 'Class', value: character.character_class&.name || 'Unknown', inline: true },
          { name: 'Level', value: character.level.to_s, inline: true }
        ]
      )
    end

    def notify_level_up(character, old_level, new_level)
      send_embed(
        title: '🎉 Level Up!',
        description: "**#{character.name}** has reached level #{new_level}!",
        color: 0xFFD700,
        fields: [
          { name: 'Previous Level', value: old_level.to_s, inline: true },
          { name: 'New Level', value: new_level.to_s, inline: true },
          { name: 'Class', value: character.character_class&.name || 'Unknown', inline: true }
        ]
      )
    end

    def notify_combat_victory(session, enemies_defeated)
      send_embed(
        title: '⚔️ Victory!',
        description: "Combat concluded successfully.",
        color: 0x22C55E,
        fields: [
          { name: 'Enemies Defeated', value: enemies_defeated.to_s, inline: true },
          { name: 'Session', value: session.title, inline: true }
        ]
      )
    end

    def notify_character_death(character)
      send_embed(
        title: '💀 Fallen Hero',
        description: "**#{character.name}** has fallen in battle.",
        color: 0xEF4444,
        fields: [
          { name: 'Level', value: character.level.to_s, inline: true },
          { name: 'Class', value: character.character_class&.name || 'Unknown', inline: true }
        ],
        footer: 'May they rest in peace'
      )
    end

    def notify_pending_approval(action, user)
      send_embed(
        title: '⚠️ Approval Required',
        description: "The DM wants to: **#{action.description}**",
        color: 0xF59E0B,
        fields: [
          { name: 'Reason', value: action.reason || 'No reason provided', inline: false },
          { name: 'Action ID', value: action.id.to_s, inline: true },
          { name: 'Expires', value: action.expires_at&.strftime('%H:%M') || 'Never', inline: true }
        ],
        footer: "Use !dnd approve #{action.id} or !dnd reject #{action.id}"
      )
    end

    def notify_critical_roll(character, roll_type, result)
      emoji = result == 20 ? '🎯' : '💥'
      title = result == 20 ? 'Natural 20!' : 'Critical Fail!'
      color = result == 20 ? 0xFFD700 : 0xEF4444

      send_embed(
        title: "#{emoji} #{title}",
        description: "**#{character.name}** rolled a natural #{result} on #{roll_type}!",
        color: color
      )
    end

    def notify_item_found(character, item, source = nil)
      send_embed(
        title: '✨ Treasure Found!',
        description: "**#{character.name}** found **#{item.name}**",
        color: rarity_color(item.rarity),
        fields: [
          { name: 'Rarity', value: item.rarity&.humanize || 'Common', inline: true },
          { name: 'Source', value: source || 'Unknown', inline: true }
        ]
      )
    end

    def notify_quest_completed(session, quest_name, rewards = nil)
      fields = [{ name: 'Quest', value: quest_name, inline: false }]
      fields << { name: 'Rewards', value: rewards, inline: false } if rewards

      send_embed(
        title: '🏆 Quest Completed!',
        description: "Adventure milestone reached!",
        color: 0xFFD700,
        fields: fields
      )
    end

    # Bulk notification for multiple users
    def self.notify_all(users, method, *args)
      users.select(&:notify_via_discord?).each do |user|
        next unless user.discord_webhook_url.present?

        service = new(user.discord_webhook_url)
        service.public_send(method, *args)
      rescue StandardError => e
        Rails.logger.error "[Discord Webhook] Failed for user #{user.id}: #{e.message}"
      end
    end

    private

    def rarity_color(rarity)
      case rarity&.downcase
      when 'common' then 0x9CA3AF
      when 'uncommon' then 0x22C55E
      when 'rare' then 0x3B82F6
      when 'very_rare' then 0x8B5CF6
      when 'legendary' then 0xF59E0B
      when 'artifact' then 0xEF4444
      else 0x9CA3AF
      end
    end
  end
end
