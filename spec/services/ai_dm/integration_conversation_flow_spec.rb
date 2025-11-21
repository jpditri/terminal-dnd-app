# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AI DM Conversation Flow Integration', type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123', username: 'testuser') }
  let(:campaign) { Campaign.create!(name: 'Test Campaign', dm_id: user.id) }
  let(:race) { Race.create!(name: 'Human', size: 'Medium', speed: 30) }
  let(:char_class) { CharacterClass.create!(name: 'Fighter', hit_die: 10, primary_ability: 'Strength') }

  let(:character) do
    Character.create!(
      user: user,
      campaign: campaign,
      name: 'Test Hero',
      race: race,
      character_class: char_class,
      level: 3,
      experience: 900,
      proficiency_bonus: 2,
      strength: 16,
      dexterity: 14,
      constitution: 15,
      intelligence: 10,
      wisdom: 12,
      charisma: 8,
      hit_points_current: 30,
      hit_points_max: 30,
      armor_class: 16,
      speed: 30,
      gold: 50
    )
  end

  let(:terminal_session) do
    TerminalSession.create!(
      user: user,
      character: character,
      campaign: campaign,
      mode: 'exploration',
      active: true
    )
  end

  let(:orchestrator) { AiDm::Orchestrator.new(terminal_session) }

  describe 'Full conversation flow with context building' do
    it 'successfully builds context without missing method errors' do
      # Test that character_context builds without errors
      expect { orchestrator.send(:character_context) }.not_to raise_error

      # Test that game_state_context builds without errors
      expect { orchestrator.send(:game_state_context) }.not_to raise_error

      # Test that build_dm_context (which calls all context methods) works
      expect { orchestrator.send(:build_dm_context) }.not_to raise_error

      context = orchestrator.send(:build_dm_context)
      expect(context).to be_a(String)
      expect(context).to include('Test Hero')
      expect(context).to include('Gold: 50') # Verify gold is included
    end

    it 'validates all character attributes used in character_context' do
      # This test verifies that all methods called in character_context exist
      character_context = orchestrator.send(:character_context)

      # Check that all expected attributes are present
      expect(character_context).to include(character.name)
      expect(character_context).to include(character.race&.name || 'Unknown')
      expect(character_context).to include(character.character_class&.name || 'Unknown')
      expect(character_context).to include("Level #{character.level}")
      expect(character_context).to include("HP: #{character.hit_points_current}/#{character.hit_points_max}")
      expect(character_context).to include("AC: #{character.calculated_armor_class}")
      expect(character_context).to include("STR #{character.strength}")
      expect(character_context).to include("Gold: #{character.gold}")
      expect(character_context).to include("XP: #{character.experience}")
    end

    it 'successfully processes a simple message without tool calls' do
      # Skip this test if Ollama is not available
      skip 'Ollama not available' unless ollama_available?

      # This will exercise the full flow including context building
      conversation_history = []

      expect do
        response = orchestrator.process_message('Hello, what do you see?', conversation_history)
        expect(response).to have_key(:narrative)
        expect(response).to have_key(:tool_results)
        expect(response).to have_key(:quick_actions)
      end.not_to raise_error
    end

    it 'validates format_modifier helper method' do
      # Test the format_modifier method with various values
      expect(orchestrator.send(:format_modifier, 16)).to eq('+3')
      expect(orchestrator.send(:format_modifier, 10)).to eq('+0')
      expect(orchestrator.send(:format_modifier, 8)).to eq('-1')
      expect(orchestrator.send(:format_modifier, nil)).to eq('+0')
    end
  end

  describe 'Combat context integration' do
    let(:combat) do
      Combat.create!(
        game_session_id: nil,
        status: 'active',
        current_round: 1,
        current_turn: 0
      )
    end

    let(:combat_participant) do
      CombatParticipant.create!(
        combat: combat,
        character: character,
        initiative: 15,
        current_hit_points: 30,
        max_hit_points: 30,
        armor_class: 16,
        name: character.name
      )
    end

    before do
      combat_participant # Create the participant
    end

    it 'builds combat context without missing method errors' do
      # Mock the find_active_combat to return our combat
      allow(orchestrator).to receive(:find_active_combat).and_return(combat)

      expect { orchestrator.send(:combat_context) }.not_to raise_error

      combat_context = orchestrator.send(:combat_context)
      expect(combat_context).to be_a(String)
      expect(combat_context).to include('COMBAT ACTIVE')
    end
  end

  describe 'NPC spawning decision engine integration' do
    it 'successfully gets NPC spawn recommendations' do
      context = {
        location: 'tavern',
        scene_description: 'You enter a bustling tavern filled with patrons'
      }

      expect { orchestrator.get_npc_spawn_recommendation(context) }.not_to raise_error

      recommendation = orchestrator.get_npc_spawn_recommendation(context)
      expect(recommendation).to be_a(Hash)
      expect(recommendation).to have_key(:recommended)
    end

    it 'successfully checks if NPC should be spawned' do
      context = {
        location: 'wilderness',
        scene_description: 'You are in the deep wilderness'
      }

      expect { orchestrator.should_spawn_npc?(context) }.not_to raise_error

      result = orchestrator.should_spawn_npc?(context)
      expect(result).to be_a(Hash)
      expect(result).to have_key(:should_spawn)
    end
  end

  describe 'Tool Registry validation' do
    it 'validates all registered tools have valid parameter schemas' do
      tools = AiDm::ToolRegistry.for_claude_api

      expect(tools).to be_an(Array)
      expect(tools).not_to be_empty

      tools.each do |tool|
        # Check basic tool structure
        expect(tool).to have_key(:name)
        expect(tool).to have_key(:description)

        # If tool has parameters, validate structure
        if tool[:input_schema]
          schema = tool[:input_schema]
          expect(schema).to have_key(:type)
          expect(schema).to have_key(:properties)
        end
      end
    end
  end

  describe 'Dialogue service integration' do
    let(:npc) do
      Npc.create!(
        campaign: campaign,
        name: 'Bartender Bob',
        occupation: 'Innkeeper',
        age: 45,
        personality_traits: 'Friendly and talkative',
        ideals: 'Hospitality',
        bonds: 'My tavern is my life',
        flaws: 'Gossips too much',
        voice_style: 'Jovial and welcoming',
        speech_patterns: 'Uses many pleasantries',
        motivations: { primary: 'Keep customers happy' },
        secrets: { hidden: 'Used to be an adventurer' },
        strength: 12,
        dexterity: 10,
        constitution: 14,
        intelligence: 11,
        wisdom: 13,
        charisma: 15,
        armor_class: 10,
        hit_points: 20,
        max_hit_points: 20,
        level: 1
      )
    end

    let(:dialogue_service) { SoloPlay::NpcDialogueService.new(npc) }

    it 'initializes dialogue service without errors' do
      expect { dialogue_service }.not_to raise_error
      expect(dialogue_service.npc).to eq(npc)
    end

    it 'builds NPC persona without missing method errors' do
      persona = dialogue_service.send(:build_npc_persona)

      expect(persona).to be_a(String)
      expect(persona).to include(npc.name)
      expect(persona).to include(npc.occupation)
      expect(persona).to include(npc.personality_traits)
    end

    it 'generates greeting without errors' do
      # Skip if Ollama not available
      skip 'Ollama not available' unless ollama_available?

      expect do
        greeting = dialogue_service.generate_greeting(
          character_id: character.id,
          location: 'tavern',
          time_of_day: 'evening'
        )
        expect(greeting).to be_a(String)
      end.not_to raise_error
    end
  end

  # Helper method to check if Ollama is available
  def ollama_available?
    return @ollama_available if defined?(@ollama_available)

    @ollama_available = begin
      ENV['ANTHROPIC_API_KEY'].blank? && system('curl -s http://localhost:11434/api/tags > /dev/null 2>&1')
    rescue StandardError
      false
    end
  end
end
