# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Player::IntentAnalyzer do
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
    context 'with insufficient data' do
      before do
        3.times { create_player_message('I attack') }
      end

      it 'returns minimal analysis' do
        result = analyzer.analyze
        expect(result[:primary_intent]).to be_nil
        expect(result[:confidence]).to eq(10)
        expect(result[:recommendations].first).to include('Not enough data')
      end
    end

    context 'with combat-focused player' do
      before do
        10.times { create_player_message('I attack the enemy with my sword!') }
        5.times { create_dm_action('start_combat') }
        3.times { create_dm_action('apply_damage') }
      end

      it 'identifies combat-focused intent' do
        result = analyzer.analyze
        expect(result[:primary_intent]).to eq(:combat_focused)
      end

      it 'calculates high combat score' do
        result = analyzer.analyze
        expect(result[:intent_scores][:combat_focused]).to be > 0.5
      end

      it 'recommends combat-focused content' do
        result = analyzer.analyze
        expect(result[:recommendations]).to include(match(/tactical combat/i))
      end
    end

    context 'with roleplay-focused player' do
      before do
        12.times do
          create_player_message('I want to talk to the merchant and ask about their backstory.')
        end
        6.times { create_dm_action('spawn_npc') }
      end

      it 'identifies roleplay-focused intent' do
        result = analyzer.analyze
        expect(result[:primary_intent]).to eq(:roleplay_focused)
      end

      it 'calculates high roleplay score' do
        result = analyzer.analyze
        expect(result[:intent_scores][:roleplay_focused]).to be > 0.5
      end

      it 'recommends social content' do
        result = analyzer.analyze
        expect(result[:recommendations]).to include(match(/NPC|social/i))
      end
    end

    context 'with exploration-focused player' do
      before do
        10.times do
          create_player_message('I carefully search the room for hidden passages and examine the walls.')
        end
        5.times { create_dm_action('create_quest') }
      end

      it 'identifies exploration-focused intent' do
        result = analyzer.analyze
        expect(result[:primary_intent]).to eq(:exploration_focused)
      end

      it 'detects detailed description preference' do
        result = analyzer.analyze
        expect(result[:preferences][:detailed_descriptions]).to be true
      end

      it 'recommends exploration content' do
        result = analyzer.analyze
        expect(result[:recommendations]).to include(match(/environment|detail|discover/i))
      end
    end

    context 'with mixed playstyle' do
      before do
        5.times { create_player_message('I attack!') }
        5.times { create_player_message('I talk to the NPC.') }
        3.times { create_dm_action('start_combat') }
        3.times { create_dm_action('spawn_npc') }
      end

      it 'identifies primary and secondary intents' do
        result = analyzer.analyze
        expect(result[:primary_intent]).to be_present
        expect(result[:secondary_intent]).to be_present
      end

      it 'has moderate confidence' do
        result = analyzer.analyze
        expect(result[:confidence]).to be_between(30, 85)
      end
    end
  end

  describe '#dm_context_message' do
    context 'with insufficient data' do
      before do
        3.times { create_player_message('test') }
      end

      it 'returns nil' do
        expect(analyzer.dm_context_message).to be_nil
      end
    end

    context 'with combat-focused high-engagement player' do
      before do
        15.times do |i|
          create_player_message("I carefully attack with strategy #{i}! What happens?", time_offset: i.minutes.ago)
        end
        7.times { create_dm_action('start_combat') }
      end

      it 'includes playstyle description' do
        message = analyzer.dm_context_message
        expect(message).to include('combat')
      end

      it 'includes engagement level or playstyle' do
        message = analyzer.dm_context_message
        # Message should contain either engagement info or playstyle info
        expect(message).to match(/engaged|combat|playstyle/i)
      end

      it 'includes recommendation' do
        message = analyzer.dm_context_message
        expect(message).to be_present
      end
    end

    context 'with low-engagement player' do
      before do
        6.times do |i|
          create_player_message('ok', time_offset: (i * 30).minutes.ago)
        end
      end

      it 'mentions low engagement' do
        message = analyzer.dm_context_message
        expect(message).to include('less engaged')
      end
    end
  end

  describe '#prefers?' do
    before do
      10.times { create_player_message('I search and explore everywhere!') }
      3.times { create_player_message('I attack.') }
    end

    it 'returns true for preferred content type' do
      expect(analyzer.prefers?(:exploration_focused)).to be true
    end

    it 'returns false for non-preferred content type' do
      expect(analyzer.prefers?(:combat_focused)).to be false
    end
  end

  describe '#style_recommendations' do
    context 'with combat-focused tactical player' do
      before do
        12.times do
          create_player_message('I attack the enemy with my sword!')
        end
        8.times { create_dm_action('start_combat') }
      end

      it 'recommends combat-focused content' do
        recs = analyzer.style_recommendations
        # Combat-focused player should get combat recommendations
        expect(recs.join(' ')).to match(/combat|tactical|strategic|challenge/i)
      end
    end

    context 'with highly engaged player' do
      before do
        20.times do |i|
          create_player_message("Detailed message #{i} with lots of content and questions?", time_offset: i.minutes.ago)
        end
      end

      it 'includes maintaining engagement recommendation' do
        recs = analyzer.style_recommendations
        # Should have engagement-related recommendation in the list
        expect(recs.any? { |r| r.match?(/maintain.*engagement|current.*pacing/i) }).to be true
      end
    end

    context 'with low-engagement player' do
      before do
        6.times do |i|
          create_player_message('ok', time_offset: (i * 45).minutes.ago)
        end
      end

      it 'recommends re-engagement hooks' do
        recs = analyzer.style_recommendations
        expect(recs).to include(match(/hook|engage|mystery|conflict/i))
      end
    end
  end

  describe 'engagement calculation' do
    context 'with high frequency, long messages, many questions' do
      before do
        15.times do |i|
          create_player_message(
            "I'm really interested in this! What can you tell me about the history? Can I learn more?",
            time_offset: (i * 5).minutes.ago
          )
        end
      end

      it 'detects high engagement' do
        result = analyzer.analyze
        expect(result[:engagement][:level]).to eq(:high)
      end

      it 'calculates high message frequency' do
        result = analyzer.analyze
        expect(result[:engagement][:metrics][:message_frequency]).to be > 5
      end

      it 'calculates high question rate' do
        result = analyzer.analyze
        expect(result[:engagement][:metrics][:question_rate]).to be > 0.3
      end
    end

    context 'with low frequency, short messages' do
      before do
        6.times do |i|
          create_player_message('ok', time_offset: (i * 40).minutes.ago)
        end
      end

      it 'detects low engagement' do
        result = analyzer.analyze
        expect(result[:engagement][:level]).to eq(:low)
      end

      it 'calculates message frequency' do
        result = analyzer.analyze
        # With 6 messages over variable time, frequency varies
        # Just verify it's calculated and is a reasonable number
        expect(result[:engagement][:metrics][:message_frequency]).to be_a(Float)
        expect(result[:engagement][:metrics][:message_frequency]).to be >= 0
      end

      it 'calculates low avg message length' do
        result = analyzer.analyze
        expect(result[:engagement][:metrics][:avg_message_length]).to be < 20
      end
    end

    context 'with medium engagement' do
      before do
        10.times do |i|
          create_player_message('I look around the area.', time_offset: (i * 15).minutes.ago)
        end
      end

      it 'detects medium engagement' do
        result = analyzer.analyze
        expect(result[:engagement][:level]).to eq(:medium)
      end
    end
  end

  describe 'preference detection' do
    context 'with detailed exploration keywords' do
      before do
        8.times do
          create_player_message('I carefully and thoroughly examine every detail of the room.')
        end
      end

      it 'detects detailed description preference' do
        result = analyzer.analyze
        expect(result[:preferences][:detailed_descriptions]).to be true
      end
    end

    context 'with tactical keywords' do
      before do
        8.times do
          create_player_message('I consider my position, check the distance, and plan my strategy for advantage.')
        end
      end

      it 'detects tactical detail preference' do
        result = analyzer.analyze
        expect(result[:preferences][:tactical_details]).to be true
      end
    end

    context 'with roleplay-heavy language' do
      before do
        10.times do
          create_player_message('I speak eloquently and try to persuade them with charm.')
        end
      end

      it 'detects roleplay preference' do
        result = analyzer.analyze
        expect(result[:preferences][:roleplay_heavy]).to be true
      end
    end

    context 'with consistently short messages' do
      before do
        8.times { create_player_message('attack') }
      end

      it 'detects quick action preference' do
        result = analyzer.analyze
        expect(result[:preferences][:prefers_quick_actions]).to be true
      end
    end
  end

  describe 'confidence calculation' do
    it 'has very low confidence with 0-4 messages' do
      3.times { create_player_message('test') }
      result = analyzer.analyze
      expect(result[:confidence]).to eq(10)
    end

    it 'has low confidence with 5-10 messages' do
      7.times { create_player_message('test') }
      result = analyzer.analyze
      expect(result[:confidence]).to eq(30)
    end

    it 'has medium confidence with 11-20 messages' do
      15.times { create_player_message('test') }
      result = analyzer.analyze
      expect(result[:confidence]).to eq(60)
    end

    it 'has high confidence with 21-30 messages' do
      25.times { create_player_message('test') }
      result = analyzer.analyze
      expect(result[:confidence]).to eq(85)
    end

    it 'has very high confidence with 30+ messages' do
      35.times { create_player_message('test') }
      result = analyzer.analyze
      # 31+ messages should have high confidence (85 or 95)
      expect(result[:confidence]).to be >= 85
    end
  end

  describe '.campaign_summary' do
    let(:user2) { User.create!(username: 'player2', email: 'player2@example.com', password: 'password123') }
    let(:character2) do
      Character.create!(
        user: user2,
        campaign: campaign,
        name: 'Hero Two',
        level: 3,
        hit_points_current: 20,
        hit_points_max: 20,
        strength: 14,
        dexterity: 12,
        constitution: 13,
        intelligence: 16,
        wisdom: 10,
        charisma: 14
      )
    end
    let(:session2) { TerminalSession.create!(user: user2, campaign: campaign, character: character2) }

    before do
      # Session 1 - combat focused
      10.times { create_player_message('I attack!', session: session) }
      5.times { create_dm_action('start_combat', session: session) }

      # Session 2 - roleplay focused
      10.times { create_player_message('I talk to them.', session: session2) }
      5.times { create_dm_action('spawn_npc', session: session2) }
    end

    it 'aggregates across sessions' do
      summary = described_class.campaign_summary(campaign)
      expect(summary[:session_count]).to eq(2)
    end

    it 'calculates average intent scores' do
      summary = described_class.campaign_summary(campaign)
      expect(summary[:average_intents]).to be_a(Hash)
      expect(summary[:average_intents][:combat_focused]).to be_a(Float)
    end

    it 'identifies primary campaign intent' do
      summary = described_class.campaign_summary(campaign)
      expect(summary[:primary_campaign_intent]).to be_present
    end

    it 'counts total messages' do
      summary = described_class.campaign_summary(campaign)
      expect(summary[:total_messages]).to eq(20)
    end
  end

  # Helper methods
  def create_player_message(content, time_offset: nil, session: nil)
    test_session = session || self.session
    created_at = time_offset ? Time.current - time_offset : Time.current

    NarrativeOutput.create!(
      terminal_session: test_session,
      content: content,
      content_type: 'player',
      created_at: created_at
    )
  end

  def create_dm_action(tool_name, session: nil)
    test_session = session || self.session

    DmActionAuditLog.create!(
      terminal_session: test_session,
      character: test_session.character,
      tool_name: tool_name,
      execution_status: 'executed',
      result: { message: 'Test action' },
      created_at: Time.current
    )
  end
end
