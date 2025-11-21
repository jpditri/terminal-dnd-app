# frozen_string_literal: true

namespace :discord do
  desc 'Start the Discord bot (foreground)'
  task start: :environment do
    puts 'Starting Discord bot...'

    token = Rails.application.credentials.dig(:discord, :bot_token)
    if token.blank?
      puts 'ERROR: Discord bot token not configured'
      puts 'Run: rails credentials:edit'
      exit 1
    end

    bot_service = Discord::BotService.new

    # Handle graceful shutdown
    trap('INT') do
      puts "\nShutting down..."
      bot_service.stop
      exit 0
    end

    trap('TERM') do
      puts "\nTerminating..."
      bot_service.stop
      exit 0
    end

    bot_service.start
    puts 'Bot is running! Press Ctrl+C to stop.'

    # Keep running
    loop { sleep 1 }
  end

  desc 'Start the Discord bot via Sidekiq job'
  task start_job: :environment do
    puts 'Enqueueing Discord bot job...'
    DiscordBotJob.perform_later
    puts 'Job enqueued. Make sure Sidekiq is running.'
  end

  desc 'Test webhook notification'
  task test_webhook: :environment do
    webhook_url = Rails.application.credentials.dig(:discord, :webhook_url)

    if webhook_url.blank?
      puts 'ERROR: Webhook URL not configured'
      exit 1
    end

    service = Discord::WebhookService.new(webhook_url)
    service.send_embed(
      title: '🧪 Test Notification',
      description: 'Discord webhook is working correctly!',
      color: 0x22C55E,
      fields: [
        { name: 'Environment', value: Rails.env, inline: true },
        { name: 'Time', value: Time.current.to_s, inline: true }
      ]
    )

    puts 'Test notification sent!'
  end

  desc 'Send a custom message to webhook'
  task :message, [:text] => :environment do |_t, args|
    webhook_url = Rails.application.credentials.dig(:discord, :webhook_url)

    if webhook_url.blank?
      puts 'ERROR: Webhook URL not configured'
      exit 1
    end

    if args[:text].blank?
      puts 'Usage: rails discord:message["Your message here"]'
      exit 1
    end

    service = Discord::WebhookService.new(webhook_url)
    service.send_message(args[:text])
    puts 'Message sent!'
  end
end
