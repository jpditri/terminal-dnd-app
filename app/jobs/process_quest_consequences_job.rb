# frozen_string_literal: true

# Background job to process quest consequences across all campaigns
# Runs periodically to:
# - Check for quests that should have consequences applied
# - Auto-resolve quests that have expired
# - Update quest state based on ConsequenceManager logic
class ProcessQuestConsequencesJob < ApplicationJob
  queue_as :default

  # Retry with polynomial backoff on errors
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform
    Rails.logger.info '[ProcessQuestConsequencesJob] Starting quest consequence processing...'

    processed_count = 0
    consequence_count = 0
    auto_resolved_count = 0

    Campaign.find_each do |campaign|
      Rails.logger.debug "[ProcessQuestConsequencesJob] Processing campaign: #{campaign.name} (ID: #{campaign.id})"

      # Track state changes
      before_state = capture_quest_state(campaign)

      # Process all quests in the campaign
      Quest::ConsequenceManager.process_campaign_quests(campaign)

      # Calculate what changed
      after_state = capture_quest_state(campaign)
      delta = calculate_state_delta(before_state, after_state)

      processed_count += 1
      consequence_count += delta[:consequences_applied]
      auto_resolved_count += delta[:auto_resolved]

      if delta[:consequences_applied] > 0 || delta[:auto_resolved] > 0
        Rails.logger.info "[ProcessQuestConsequencesJob] Campaign '#{campaign.name}': " \
                         "#{delta[:consequences_applied]} consequences applied, " \
                         "#{delta[:auto_resolved]} quests auto-resolved"
      end
    end

    Rails.logger.info "[ProcessQuestConsequencesJob] Completed processing #{processed_count} campaigns: " \
                     "#{consequence_count} total consequences applied, " \
                     "#{auto_resolved_count} quests auto-resolved"

    {
      processed_campaigns: processed_count,
      consequences_applied: consequence_count,
      quests_auto_resolved: auto_resolved_count
    }
  rescue StandardError => e
    Rails.logger.error "[ProcessQuestConsequencesJob] Fatal error: #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    raise
  end

  private

  # Capture current quest state for a campaign
  def capture_quest_state(campaign)
    # Include all statuses to track quests that get auto-resolved
    all_quests = campaign.quest_logs
    {
      with_consequences: all_quests.where(consequence_applied: true).count,
      with_resolution: all_quests.where.not(resolution_type: nil).count
    }
  end

  # Calculate what changed between before and after states
  def calculate_state_delta(before_state, after_state)
    {
      consequences_applied: after_state[:with_consequences] - before_state[:with_consequences],
      auto_resolved: after_state[:with_resolution] - before_state[:with_resolution]
    }
  end
end
