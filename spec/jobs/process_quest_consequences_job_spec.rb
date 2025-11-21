# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessQuestConsequencesJob, type: :job do
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

  describe '#perform' do
    it 'processes all campaigns' do
      campaign1 = Campaign.create!(name: 'Campaign 1')
      campaign2 = Campaign.create!(name: 'Campaign 2')

      result = described_class.new.perform

      expect(result[:processed_campaigns]).to eq(2)
    end

    it 'applies consequences to ignored quests' do
      quest = QuestLog.create!(
        character: character,
        campaign: campaign,
        title: 'Ignored Quest',
        description: 'A quest that has been ignored',
        status: 'available',
        quest_type: 'rescue',
        presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD
      )

      result = described_class.new.perform

      expect(quest.reload.consequence_applied).to be true
      expect(result[:consequences_applied]).to eq(1)
    end

    it 'auto-resolves expired quests' do
      quest = QuestLog.create!(
        character: character,
        campaign: campaign,
        title: 'Old Quest',
        description: 'A quest that expired',
        status: 'active',
        quest_type: 'rescue',
        started_at: 15.days.ago
      )

      result = described_class.new.perform

      expect(quest.reload.status).to eq('failed')
      expect(quest.resolution_type).to eq('rescue_failed')
      expect(result[:quests_auto_resolved]).to eq(1)
    end

    it 'returns zero counts when no changes needed' do
      # Create quest that doesn't need processing
      QuestLog.create!(
        character: character,
        campaign: campaign,
        title: 'New Quest',
        description: 'A fresh quest',
        status: 'available',
        quest_type: 'rescue',
        presentation_count: 1
      )

      result = described_class.new.perform

      expect(result[:consequences_applied]).to eq(0)
      expect(result[:quests_auto_resolved]).to eq(0)
    end

    it 'processes multiple campaigns with different quest states' do
      # Campaign 1 - ignored quest
      campaign1 = Campaign.create!(name: 'Campaign 1')
      char1 = Character.create!(
        user: user,
        campaign: campaign1,
        name: 'Hero 1',
        level: 1,
        hit_points_current: 10,
        hit_points_max: 10,
        strength: 10,
        dexterity: 10,
        constitution: 10,
        intelligence: 10,
        wisdom: 10,
        charisma: 10
      )
      QuestLog.create!(
        character: char1,
        campaign: campaign1,
        title: 'Ignored Quest',
        status: 'available',
        quest_type: 'rescue',
        presentation_count: Quest::ConsequenceManager::IGNORE_THRESHOLD
      )

      # Campaign 2 - expired quest
      campaign2 = Campaign.create!(name: 'Campaign 2')
      char2 = Character.create!(
        user: user,
        campaign: campaign2,
        name: 'Hero 2',
        level: 1,
        hit_points_current: 10,
        hit_points_max: 10,
        strength: 10,
        dexterity: 10,
        constitution: 10,
        intelligence: 10,
        wisdom: 10,
        charisma: 10
      )
      QuestLog.create!(
        character: char2,
        campaign: campaign2,
        title: 'Expired Quest',
        status: 'active',
        quest_type: 'delivery',
        started_at: 15.days.ago
      )

      result = described_class.new.perform

      expect(result[:processed_campaigns]).to eq(2)
      expect(result[:consequences_applied]).to eq(1)
      expect(result[:quests_auto_resolved]).to eq(1)
    end

    it 'logs processing information' do
      campaign

      expect(Rails.logger).to receive(:info).with(/Starting quest consequence processing/)
      expect(Rails.logger).to receive(:info).with(/Completed processing/)

      described_class.new.perform
    end

    it 'handles campaigns with no quests' do
      Campaign.create!(name: 'Empty Campaign')

      expect { described_class.new.perform }.not_to raise_error
    end

    context 'error handling' do
      it 'logs errors and re-raises when processing fails' do
        allow(Campaign).to receive(:find_each).and_raise(StandardError, 'Database error')

        expect { described_class.new.perform }.to raise_error(StandardError, 'Database error')
      end
    end
  end
end
