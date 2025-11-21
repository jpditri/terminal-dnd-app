# frozen_string_literal: true

module Quest
  # Manages quest consequences and escalation to prevent railroad feel
  # Tracks quest presentation, applies natural consequences when ignored,
  # and allows quests to resolve without player intervention
  class ConsequenceManager
    IGNORE_THRESHOLD = 3 # Number of times a quest can be ignored before consequences
    DAYS_BEFORE_AUTO_RESOLVE = 14 # Days before quest resolves itself

    attr_reader :quest, :campaign

    def initialize(quest)
      @quest = quest
      @campaign = quest.campaign
    end

    # Record that this quest was presented to the player
    def record_presentation
      quest.increment!(:presentation_count)
      quest.update!(last_presented_at: Time.current)

      check_for_consequences if quest.presentation_count >= IGNORE_THRESHOLD
    end

    # Check if quest should have consequences applied
    def check_for_consequences
      return if quest.consequence_applied?
      return if quest.status == 'completed' || quest.status == 'failed'

      if should_apply_consequences?
        apply_minor_consequences
        quest.update!(
          consequence_applied: true,
          escalation_level: calculate_escalation_level
        )
      end
    end

    # Allow quest to resolve naturally without player
    def auto_resolve_if_expired
      return unless quest.started_at
      return if quest.status == 'completed' || quest.status == 'failed'

      days_since_start = (Time.current - quest.started_at) / 1.day

      if days_since_start >= DAYS_BEFORE_AUTO_RESOLVE
        resolve_quest_naturally
      end
    end

    # Get context message for AI DM about quest state
    def context_message
      return nil unless quest.presentation_count > 0

      messages = []

      if quest.presentation_count >= IGNORE_THRESHOLD
        messages << "Quest '#{quest.title}' has been ignored #{quest.presentation_count} times."
      end

      if quest.consequence_applied?
        messages << "Consequences have been applied (escalation level: #{quest.escalation_level})."
      end

      if quest.resolution_type.present?
        messages << "Quest resolved itself: #{quest.resolution_type}."
      end

      messages.join(' ')
    end

    # Determine if quest should be presented again
    def should_present_again?
      return false if quest.resolution_type.present? # Already auto-resolved
      return false if quest.status == 'completed' || quest.status == 'failed'

      # Don't spam the player - space out presentations
      return true if quest.presentation_count.zero?
      return false if quest.last_presented_at && quest.last_presented_at > 2.hours.ago

      # After many ignores, stop presenting (let it auto-resolve)
      quest.presentation_count < IGNORE_THRESHOLD * 2
    end

    private

    def should_apply_consequences?
      quest.presentation_count >= IGNORE_THRESHOLD &&
        !quest.consequence_applied? &&
        quest.status != 'completed' &&
        quest.status != 'failed'
    end

    def apply_minor_consequences
      # Store consequence data in milestone_data JSONB field
      consequences = {
        type: 'ignored_too_long',
        applied_at: Time.current,
        presentation_count: quest.presentation_count,
        consequences: generate_consequence_description
      }

      current_data = quest.milestone_data || {}
      current_data['consequences'] ||= []
      current_data['consequences'] << consequences

      quest.update!(milestone_data: current_data)

      Rails.logger.info("Applied consequences to quest #{quest.id}: #{consequences[:consequences]}")
    end

    def generate_consequence_description
      case quest.quest_type
      when 'rescue'
        'The captive situation has worsened. Time is running out.'
      when 'investigation'
        'The trail has grown cold. Evidence may be lost.'
      when 'delivery'
        'The recipient is growing impatient. Rewards may be reduced.'
      when 'combat'
        'The enemies have grown stronger and more organized.'
      when 'exploration'
        'Other adventurers may have found the location first.'
      else
        'The situation has evolved in your absence.'
      end
    end

    def calculate_escalation_level
      # Escalation level increases based on how many times ignored
      [quest.presentation_count - IGNORE_THRESHOLD + 1, 5].min
    end

    def resolve_quest_naturally
      resolution = determine_natural_resolution

      quest.update!(
        status: resolution[:status],
        resolution_type: resolution[:type],
        completed_at: Time.current
      )

      # Store resolution details
      current_data = quest.milestone_data || {}
      current_data['natural_resolution'] = {
        type: resolution[:type],
        description: resolution[:description],
        resolved_at: Time.current,
        days_elapsed: ((Time.current - quest.started_at) / 1.day).to_i
      }
      quest.update!(milestone_data: current_data)

      Rails.logger.info("Quest #{quest.id} auto-resolved: #{resolution[:type]}")
    end

    def determine_natural_resolution
      # Different quest types resolve differently
      case quest.quest_type
      when 'rescue'
        {
          status: 'failed',
          type: 'rescue_failed',
          description: 'Without intervention, the captive was not rescued in time.'
        }
      when 'investigation'
        {
          status: 'failed',
          type: 'case_closed',
          description: 'The investigation was closed due to lack of progress.'
        }
      when 'delivery'
        {
          status: 'failed',
          type: 'delivery_missed',
          description: 'The delivery deadline passed. Another courier was found.'
        }
      when 'combat'
        {
          status: 'failed',
          type: 'enemies_succeeded',
          description: 'The threat was not addressed and the enemies achieved their goals.'
        }
      when 'exploration'
        {
          status: 'completed',
          type: 'discovered_by_others',
          description: 'Other adventurers explored the location and claimed the discovery.'
        }
      else
        {
          status: 'failed',
          type: 'abandoned',
          description: 'The quest was abandoned and resolved without intervention.'
        }
      end
    end

    # Class method to process all active quests in a campaign
    def self.process_campaign_quests(campaign)
      campaign.quest_logs.where(status: %w[active available]).find_each do |quest|
        manager = new(quest)
        manager.check_for_consequences
        manager.auto_resolve_if_expired
      end
    end
  end
end
