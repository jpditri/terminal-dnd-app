# frozen_string_literal: true

# Background job to run the Discord bot
# This keeps the bot running persistently via Sidekiq
class DiscordBotJob < ApplicationJob
  queue_as :discord

  # Don't retry automatically - the bot should stay running
  discard_on StandardError do |job, error|
    Rails.logger.error "[DiscordBotJob] Fatal error: #{error.message}"
    Rails.logger.error error.backtrace.first(10).join("\n")

    # Attempt to restart after a delay
    DiscordBotJob.set(wait: 30.seconds).perform_later
  end

  def perform
    return unless discord_enabled?

    Rails.logger.info '[DiscordBotJob] Starting Discord bot...'

    bot_service = Discord::BotService.new
    bot_service.start

    # Keep the job alive
    loop do
      sleep 60
      break unless bot_service.bot.connected?
    end

    Rails.logger.warn '[DiscordBotJob] Bot disconnected, will restart...'
    DiscordBotJob.set(wait: 5.seconds).perform_later
  end

  private

  def discord_enabled?
    token = Rails.application.credentials.dig(:discord, :bot_token)
    if token.blank?
      Rails.logger.warn '[DiscordBotJob] Discord bot token not configured, skipping'
      return false
    end
    true
  end
end
