# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Quest::ConsequenceManager do
  include ActiveSupport::Testing::TimeHelpers
  let(:campaign) { Campaign.create!(name: 'Test Campaign') }
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123') }
  let(:character) do
    Character.create!(
      user: user,
      campaign: campaign,
      name: 'Test Hero',
      level: 5,
      hit_points_current: 40,
      hit_points_max: 40,
      strength: 16,
      dexterity: 14,
      constitution: 15,
      intelligence: 10,
      wisdom: 12,
      charisma: 8
    )
  end

  let(:quest) do
    QuestLog.create!(
      character: character,
      campaign: campaign,
      title: 'Rescue the Merchant',
      description: 'A merchant has been kidnapped by bandits',
      status: 'available',
      quest_type: 'rescue',
      difficulty: 'medium',
      gold_reward: 100,
      experience_reward: 500
    )
  end

  let(:manager) { described_class.new(quest) }

  describe '#initialize' do
    it 'sets quest and campaign' do
      expect(manager.quest).to eq(quest)
      expect(manager.campaign).to eq(campaign)
    end
  end

  describe '#record_presentation' do
    it 'increments presentation count' do
      expect { manager.record_presentation }.to change { quest.reload.presentation_count }.from(0).to(1)
    end

    it 'updates last_presented_at timestamp' do
      travel_to Time.current do
        manager.record_presentation
        expect(quest.reload.last_presented_at).to be_within(1.second).of(Time.current)
      end
    end

    context 'when presentation count reaches threshold' do
      before do
        quest.update!(presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD - 1)
      end

      it 'triggers consequence check' do
        expect(manager).to receive(:check_for_consequences)
        manager.record_presentation
      end
    end
  end

  describe '#check_for_consequences' do
    context 'when presentation count is below threshold' do
      before { quest.update!(presentation_count: 2) }

      it 'does not apply consequences' do
        manager.check_for_consequences
        expect(quest.reload.consequence_applied).to be false
      end
    end

    context 'when presentation count reaches threshold' do
      before { quest.update!(presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD) }

      it 'applies consequences' do
        manager.check_for_consequences
        expect(quest.reload.consequence_applied).to be true
      end

      it 'sets escalation level' do
        manager.check_for_consequences
        expect(quest.reload.escalation_level).to eq(1)
      end

      it 'stores consequence data in milestone_data' do
        manager.check_for_consequences
        quest.reload
        expect(quest.milestone_data['consequences']).to be_present
        expect(quest.milestone_data['consequences'].first['type']).to eq('ignored_too_long')
      end

      it 'includes type-specific consequence description' do
        manager.check_for_consequences
        quest.reload
        expect(quest.milestone_data['consequences'].first['consequences']).to include('captive')
      end
    end

    context 'when consequences already applied' do
      before do
        quest.update!(
          presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD,
          consequence_applied: true,
          escalation_level: 1
        )
      end

      it 'does not apply consequences again' do
        expect do
          manager.check_for_consequences
        end.not_to change { quest.reload.milestone_data }
      end
    end

    context 'when quest is completed' do
      before do
        quest.update!(
          presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD,
          status: 'completed'
        )
      end

      it 'does not apply consequences' do
        manager.check_for_consequences
        expect(quest.reload.consequence_applied).to be false
      end
    end
  end

  describe '#auto_resolve_if_expired' do
    context 'when quest has not started' do
      it 'does not auto-resolve' do
        manager.auto_resolve_if_expired
        expect(quest.reload.status).to eq('available')
      end
    end

    context 'when quest started less than threshold days ago' do
      before { quest.update!(started_at: 7.days.ago) }

      it 'does not auto-resolve' do
        manager.auto_resolve_if_expired
        expect(quest.reload.status).to eq('available')
      end
    end

    context 'when quest started more than threshold days ago' do
      before { quest.update!(started_at: 15.days.ago) }

      it 'auto-resolves the quest' do
        manager.auto_resolve_if_expired
        expect(quest.reload.status).to eq('failed')
      end

      it 'sets resolution_type' do
        manager.auto_resolve_if_expired
        expect(quest.reload.resolution_type).to eq('rescue_failed')
      end

      it 'sets completed_at timestamp' do
        travel_to Time.current do
          manager.auto_resolve_if_expired
          expect(quest.reload.completed_at).to be_within(1.second).of(Time.current)
        end
      end

      it 'stores natural resolution data' do
        manager.auto_resolve_if_expired
        quest.reload
        expect(quest.milestone_data['natural_resolution']).to be_present
        expect(quest.milestone_data['natural_resolution']['type']).to eq('rescue_failed')
      end
    end

    context 'different quest types auto-resolve differently' do
      it 'investigation quests fail with case_closed' do
        quest.update!(quest_type: 'investigation', started_at: 15.days.ago)
        manager.auto_resolve_if_expired
        expect(quest.reload.resolution_type).to eq('case_closed')
        expect(quest.status).to eq('failed')
      end

      it 'delivery quests fail with delivery_missed' do
        quest.update!(quest_type: 'delivery', started_at: 15.days.ago)
        manager.auto_resolve_if_expired
        expect(quest.reload.resolution_type).to eq('delivery_missed')
        expect(quest.status).to eq('failed')
      end

      it 'combat quests fail with enemies_succeeded' do
        quest.update!(quest_type: 'combat', started_at: 15.days.ago)
        manager.auto_resolve_if_expired
        expect(quest.reload.resolution_type).to eq('enemies_succeeded')
        expect(quest.status).to eq('failed')
      end

      it 'exploration quests complete with discovered_by_others' do
        quest.update!(quest_type: 'exploration', started_at: 15.days.ago)
        manager.auto_resolve_if_expired
        expect(quest.reload.resolution_type).to eq('discovered_by_others')
        expect(quest.status).to eq('completed')
      end
    end
  end

  describe '#context_message' do
    context 'when quest has not been presented' do
      it 'returns nil' do
        expect(manager.context_message).to be_nil
      end
    end

    context 'when quest has been presented but not ignored' do
      before { quest.update!(presentation_count: 1) }

      it 'returns blank string' do
        expect(manager.context_message).to be_blank
      end
    end

    context 'when quest has been ignored multiple times' do
      before { quest.update!(presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD) }

      it 'includes presentation count' do
        message = manager.context_message
        expect(message).to include('ignored')
        expect(message).to include(Quest::ConsequenceManager::IGNORE_THRESHOLD.to_s)
      end
    end

    context 'when consequences have been applied' do
      before do
        quest.update!(
          presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD,
          consequence_applied: true,
          escalation_level: 2
        )
      end

      it 'includes consequence information' do
        message = manager.context_message
        expect(message).to include('Consequences')
        expect(message).to include('escalation level: 2')
      end
    end

    context 'when quest has auto-resolved' do
      before do
        quest.update!(
          resolution_type: 'rescue_failed',
          status: 'failed',
          completed_at: Time.current,
          presentation_count: 1
        )
      end

      it 'includes resolution information' do
        message = manager.context_message
        expect(message).to include('resolved itself')
        expect(message).to include('rescue_failed')
      end
    end
  end

  describe '#should_present_again?' do
    context 'when quest has not been presented' do
      it 'returns true' do
        expect(manager.should_present_again?).to be true
      end
    end

    context 'when quest was presented recently' do
      before { quest.update!(presentation_count: 1, last_presented_at: 1.hour.ago) }

      it 'returns false' do
        expect(manager.should_present_again?).to be false
      end
    end

    context 'when quest was presented long enough ago' do
      before { quest.update!(presentation_count: 1, last_presented_at: 3.hours.ago) }

      it 'returns true' do
        expect(manager.should_present_again?).to be true
      end
    end

    context 'when quest has been ignored too many times' do
      before do
        quest.update!(
          presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD * 2,
          last_presented_at: 3.hours.ago
        )
      end

      it 'returns false' do
        expect(manager.should_present_again?).to be false
      end
    end

    context 'when quest has auto-resolved' do
      before do
        quest.update!(
          resolution_type: 'rescue_failed',
          status: 'failed',
          completed_at: Time.current
        )
      end

      it 'returns false' do
        expect(manager.should_present_again?).to be false
      end
    end

    context 'when quest is completed' do
      before { quest.update!(status: 'completed') }

      it 'returns false' do
        expect(manager.should_present_again?).to be false
      end
    end

    context 'when quest is failed' do
      before { quest.update!(status: 'failed') }

      it 'returns false' do
        expect(manager.should_present_again?).to be false
      end
    end
  end

  describe '.process_campaign_quests' do
    let!(:quest1) do
      QuestLog.create!(
        campaign: campaign,
        character: character,
        title: 'Old Quest',
        description: 'Ancient quest',
        status: 'active',
        quest_type: 'rescue',
        presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD,
        started_at: 15.days.ago
      )
    end

    let!(:quest2) do
      QuestLog.create!(
        campaign: campaign,
        character: character,
        title: 'Recent Quest',
        description: 'New quest',
        status: 'available',
        quest_type: 'delivery',
        presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD
      )
    end

    it 'processes all active and available quests' do
      described_class.process_campaign_quests(campaign)

      # Quest 1 should auto-resolve
      expect(quest1.reload.status).to eq('failed')
      expect(quest1.resolution_type).to eq('rescue_failed')

      # Quest 2 should have consequences applied
      expect(quest2.reload.consequence_applied).to be true
    end
  end

  describe 'escalation level calculation' do
    it 'increases with presentation count' do
      quest.update!(presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD)
      manager.check_for_consequences
      expect(quest.reload.escalation_level).to eq(1)

      quest.update!(presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD + 1)
      quest.update!(consequence_applied: false, escalation_level: 0) # Reset to test again
      manager.check_for_consequences
      expect(quest.reload.escalation_level).to eq(2)
    end

    it 'caps at level 5' do
      quest.update!(presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD + 10)
      manager.check_for_consequences
      expect(quest.reload.escalation_level).to eq(5)
    end
  end

  describe 'consequence descriptions' do
    it 'generates rescue-specific consequences' do
      quest.update!(quest_type: 'rescue', presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD)
      manager.check_for_consequences
      consequences = quest.reload.milestone_data['consequences'].first['consequences']
      expect(consequences).to include('captive')
    end

    it 'generates investigation-specific consequences' do
      quest.update!(quest_type: 'investigation', presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD)
      manager.check_for_consequences
      consequences = quest.reload.milestone_data['consequences'].first['consequences']
      expect(consequences).to include('trail')
    end

    it 'generates delivery-specific consequences' do
      quest.update!(quest_type: 'delivery', presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD)
      manager.check_for_consequences
      consequences = quest.reload.milestone_data['consequences'].first['consequences']
      expect(consequences).to include('recipient')
    end

    it 'generates combat-specific consequences' do
      quest.update!(quest_type: 'combat', presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD)
      manager.check_for_consequences
      consequences = quest.reload.milestone_data['consequences'].first['consequences']
      expect(consequences).to include('enemies')
    end

    it 'generates exploration-specific consequences' do
      quest.update!(quest_type: 'exploration', presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD)
      manager.check_for_consequences
      consequences = quest.reload.milestone_data['consequences'].first['consequences']
      expect(consequences).to include('adventurers')
    end
  end
end
