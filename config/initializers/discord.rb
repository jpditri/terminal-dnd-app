# frozen_string_literal: true

# Discord configuration
Rails.application.config.after_initialize do
  # Start Discord bot in production if configured
  if Rails.env.production? && ENV['DISCORD_BOT_ENABLED'] == 'true'
    Rails.logger.info '[Discord] Scheduling bot startup...'
    DiscordBotJob.perform_later
  end
end

# Discord credentials validation
Rails.application.config.to_prepare do
  if Rails.env.development?
    token = Rails.application.credentials.dig(:discord, :bot_token)
    client_id = Rails.application.credentials.dig(:discord, :client_id)

    if token.blank? || client_id.blank?
      Rails.logger.warn <<~WARNING
        [Discord] Bot credentials not configured.
        To enable Discord integration, add to credentials:

        discord:
          bot_token: your_bot_token
          client_id: your_client_id
          webhook_url: your_webhook_url (optional)

        Run: rails credentials:edit
      WARNING
    end
  end
end
