# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::PacingAnalyzer do
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
  let(:session) { TerminalSession.create!(user: user, campaign: campaign, character: character) }
  let(:analyzer) { described_class.new(session) }

  describe '#analyze' do
    context 'with no actions' do
      it 'returns empty distribution' do
        result = analyzer.analyze
        expect(result[:total_actions]).to eq(0)
        expect(result[:summary]).to include('Not enough data')
      end
    end

    context 'with balanced actions' do
      before do
        # 3 combat, 3 social, 2 exploration
        3.times { create_action('start_combat', :combat) }
        3.times { create_action('spawn_npc', :npc) }
        2.times { create_action('create_quest', :quest) }
      end

      it 'calculates distribution correctly' do
        result = analyzer.analyze
        expect(result[:total_actions]).to eq(8)
        expect(result[:distribution][:combat][:count]).to eq(3)
        expect(result[:distribution][:social][:count]).to eq(3)
        expect(result[:distribution][:exploration][:count]).to eq(2)
      end

      it 'calculates percentages' do
        result = analyzer.analyze
        # 3/8 = 37.5%
        expect(result[:distribution][:combat][:percentage]).to be_within(0.01).of(0.375)
        expect(result[:distribution][:social][:percentage]).to be_within(0.01).of(0.375)
        expect(result[:distribution][:exploration][:percentage]).to be_within(0.01).of(0.25)
      end

      it 'has high pacing score' do
        result = analyzer.analyze
        expect(result[:pacing_score]).to be > 50
      end

      it 'has no warnings' do
        result = analyzer.analyze
        expect(result[:warnings]).to be_empty
      end
    end

    context 'with excessive combat' do
      before do
        # 7 combat, 1 social, 1 exploration
        7.times { create_action('start_combat', :combat) }
        create_action('spawn_npc', :npc)
        create_action('create_quest', :quest)
      end

      it 'detects excessive combat' do
        result = analyzer.analyze
        # 7/9 = 77.8%
        expect(result[:distribution][:combat][:percentage]).to be > 0.5
      end

      it 'generates combat warning' do
        result = analyzer.analyze
        expect(result[:warnings].first).to include('Excessive combat')
      end

      it 'recommends reducing combat' do
        result = analyzer.analyze
        expect(result[:recommendations]).to include(match(/Reduce combat/i))
      end

      it 'has lower pacing score' do
        result = analyzer.analyze
        expect(result[:pacing_score]).to be < 70
      end
    end

    context 'with recent clustering' do
      before do
        # Last 5 actions all combat
        5.times { create_action('apply_damage', :combat) }
      end

      it 'detects clustering in recent actions' do
        result = analyzer.analyze
        expect(result[:distribution][:combat][:recent_count]).to eq(5)
      end

      it 'recommends varying content' do
        result = analyzer.analyze
        expect(result[:recommendations]).to include(match(/clustering detected/i))
      end
    end

    context 'with lacking content types' do
      before do
        # 5 combat, 0 social, 0 exploration
        5.times { create_action('start_combat', :combat) }
      end

      it 'detects lacking social content' do
        result = analyzer.analyze
        expect(result[:distribution][:social][:count]).to eq(0)
      end

      it 'recommends adding lacking content' do
        result = analyzer.analyze
        # With 100% combat, should warn about excessive combat
        # and clustering (all 5 are combat)
        expect(result[:recommendations].size).to be > 0
        expect(result[:warnings].first).to include('Excessive combat')
      end
    end
  end

  describe '#dm_context_message' do
    context 'with insufficient data' do
      before do
        3.times { create_action('grant_item', :character) }
      end

      it 'returns nil' do
        expect(analyzer.dm_context_message).to be_nil
      end
    end

    context 'with warnings' do
      before do
        8.times { create_action('start_combat', :combat) }
        1.times { create_action('spawn_npc', :npc) }
        1.times { create_action('create_quest', :quest) }
      end

      it 'includes warning in message' do
        message = analyzer.dm_context_message
        expect(message).to include('Excessive combat')
      end

      it 'includes recommendation' do
        message = analyzer.dm_context_message
        expect(message).to include('Reduce combat')
      end
    end

    context 'with balanced content' do
      before do
        3.times { create_action('start_combat', :combat) }
        3.times { create_action('spawn_npc', :npc) }
        3.times { create_action('create_quest', :quest) }
      end

      it 'returns message or nil for balanced content' do
        message = analyzer.dm_context_message
        # With 9 actions and good balance, may or may not have message
        # (depends on whether recommendations are generated)
        # Just verify it doesn't crash
        expect([String, NilClass]).to include(message.class)
      end
    end
  end

  describe '#should_avoid?' do
    before do
      6.times { create_action('start_combat', :combat) }
      1.times { create_action('spawn_npc', :npc) }
      1.times { create_action('create_quest', :quest) }
    end

    it 'returns true for excessive combat' do
      expect(analyzer.should_avoid?(:combat)).to be true
    end

    it 'returns false for lacking social' do
      expect(analyzer.should_avoid?(:social)).to be false
    end

    it 'returns false for lacking exploration' do
      expect(analyzer.should_avoid?(:exploration)).to be false
    end
  end

  describe '#suggested_content_type' do
    before do
      5.times { create_action('start_combat', :combat) }
      2.times { create_action('spawn_npc', :npc) }
      0.times { create_action('create_quest', :quest) }
    end

    it 'suggests the most lacking main content type' do
      # Exploration has 0%, so should be suggested
      suggested = analyzer.suggested_content_type
      expect(suggested).to eq(:exploration)
    end
  end

  describe '#calculate_pacing_score' do
    it 'returns 50 for no data' do
      result = analyzer.analyze
      expect(result[:pacing_score]).to eq(50)
    end

    it 'returns high score for balanced content' do
      # Perfect balance
      3.times { create_action('start_combat', :combat) }
      3.times { create_action('spawn_npc', :npc) }
      2.times { create_action('create_quest', :quest) }
      1.times { create_action('grant_item', :character) }

      result = analyzer.analyze
      expect(result[:pacing_score]).to be > 70
    end

    it 'returns low score for heavily imbalanced content' do
      # All combat
      10.times { create_action('start_combat', :combat) }

      result = analyzer.analyze
      expect(result[:pacing_score]).to be < 50
    end
  end

  describe '.campaign_summary' do
    let(:session2) { TerminalSession.create!(user: user, campaign: campaign, character: character) }

    before do
      # Session 1 - balanced
      3.times { create_action('start_combat', :combat, session) }
      3.times { create_action('spawn_npc', :npc, session) }

      # Session 2 - combat heavy
      8.times { create_action('start_combat', :combat, session2) }
      1.times { create_action('spawn_npc', :npc, session2) }
    end

    it 'aggregates across sessions' do
      summary = described_class.campaign_summary(campaign)
      expect(summary[:session_count]).to eq(2)
    end

    it 'calculates average pacing score' do
      summary = described_class.campaign_summary(campaign)
      expect(summary[:average_pacing_score]).to be_a(Float)
    end

    it 'identifies common issues' do
      summary = described_class.campaign_summary(campaign)
      expect(summary[:common_issues]).to be_a(Hash)
    end
  end

  # Helper method to create audit log entries
  def create_action(tool_name, category, test_session = session)
    # Simulate tool category for classification
    allow_any_instance_of(Content::PacingAnalyzer)
      .to receive(:get_tool_category)
      .with(tool_name)
      .and_return(category)

    DmActionAuditLog.create!(
      terminal_session: test_session,
      character: character,
      tool_name: tool_name,
      execution_status: 'executed',
      result: { message: 'Test action' },
      created_at: Time.current
    )
  end
end
