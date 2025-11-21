# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Automatic Treasure Generation After Combat', type: :integration do
  let(:campaign) { Campaign.create!(name: 'Test Campaign') }
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123') }
  let(:character) do
    Character.create!(
      user: user,
      campaign: campaign,
      name: 'Test Hero',
      level: 5,
      gold: 100,
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
  let(:terminal_session) do
    TerminalSession.create!(
      user: user,
      campaign: campaign,
      character: character,
      mode: 'exploration'
    )
  end
  let(:executor) { AiDm::ToolExecutor.new(terminal_session, character) }

  describe 'end_combat with automatic treasure' do
    let(:goblin) do
      Monster.create!(
        name: 'Goblin',
        challenge_rating: 0.25,
        armor_class: 15,
        hit_dice: '2d6',
        strength: 8,
        dexterity: 14,
        constitution: 10,
        intelligence: 10,
        wisdom: 8,
        charisma: 8
      )
    end

    let(:orc) do
      Monster.create!(
        name: 'Orc',
        challenge_rating: 0.5,
        armor_class: 13,
        hit_dice: '2d8+6',
        strength: 16,
        dexterity: 12,
        constitution: 16,
        intelligence: 7,
        wisdom: 11,
        charisma: 10
      )
    end

    let(:combat) do
      Combat.create!(
        status: 'active',
        current_round: 3,
        current_turn: 0
      )
    end

    before do
      # Create combat participants with monsters
      CombatParticipant.create!(
        combat: combat,
        character: character,
        initiative: 18,
        current_hit_points: character.hit_points_current,
        max_hit_points: character.hit_points_max,
        armor_class: 16
      )

      encounter = Encounter.create!(campaign: campaign, name: 'Test Encounter')
      goblin_encounter = EncounterMonster.create!(
        encounter: encounter,
        monster: goblin,
        current_hit_points: 7,
        max_hit_points: 7
      )
      orc_encounter = EncounterMonster.create!(
        encounter: encounter,
        monster: orc,
        current_hit_points: 15,
        max_hit_points: 15
      )

      CombatParticipant.create!(
        combat: combat,
        encounter_monster: goblin_encounter,
        initiative: 12,
        current_hit_points: 0, # Defeated
        max_hit_points: 7,
        armor_class: 15
      )

      CombatParticipant.create!(
        combat: combat,
        encounter_monster: orc_encounter,
        initiative: 10,
        current_hit_points: 0, # Defeated
        max_hit_points: 15,
        armor_class: 13
      )
    end

    context 'when combat ends in victory' do
      it 'automatically generates treasure based on enemy CR' do
        initial_gold = character.gold

        result = executor.execute('end_combat', {
          outcome: 'victory'
        })

        expect(result[:success]).to be true
        expect(result[:treasure]).to be_present
        expect(result[:treasure][:generated]).to be true

        # Verify treasure was generated with correct CR
        treasure = result[:treasure]
        expect(treasure[:total_cr]).to eq(0.75) # Goblin (0.25) + Orc (0.5)
        expect(treasure[:average_cr]).to be_between(0, 1)
        expect(treasure[:treasure]).to be_present
        expect(treasure[:summary]).to be_present

        # Verify character received gold
        character.reload
        expect(character.gold).to be > initial_gold
      end

      it 'generates appropriate treasure amount for low CR enemies' do
        result = executor.execute('end_combat', {
          outcome: 'victory'
        })

        treasure_data = result[:treasure][:treasure]

        # Low CR enemies should generate modest treasure
        expect(treasure_data[:total_gold_value]).to be_between(1, 100)
      end

      it 'includes treasure summary in response message' do
        result = executor.execute('end_combat', {
          outcome: 'victory'
        })

        expect(result[:treasure][:summary]).to match(/gold/)
      end
    end

    context 'when combat ends in defeat' do
      it 'does not generate treasure' do
        result = executor.execute('end_combat', {
          outcome: 'defeat'
        })

        expect(result[:success]).to be true
        expect(result[:treasure]).to be_nil
      end
    end

    context 'when combat ends in retreat' do
      it 'does not generate treasure' do
        result = executor.execute('end_combat', {
          outcome: 'retreat'
        })

        expect(result[:success]).to be true
        expect(result[:treasure]).to be_nil
      end
    end

    context 'when combat has no monsters' do
      before do
        # Clear monster participants
        combat.combat_participants.joins(:encounter_monster).destroy_all
      end

      it 'does not generate treasure' do
        result = executor.execute('end_combat', {
          outcome: 'victory'
        })

        expect(result[:success]).to be true
        expect(result[:treasure]).to be_nil
      end
    end

    context 'with high CR enemies' do
      let(:young_dragon) do
        Monster.create!(
          name: 'Young Red Dragon',
          challenge_rating: 10,
          armor_class: 18,
          hit_dice: '17d10+85',
          strength: 23,
          dexterity: 10,
          constitution: 21,
          intelligence: 14,
          wisdom: 11,
          charisma: 19
        )
      end

      before do
        # Clear existing monsters and add dragon
        combat.combat_participants.joins(:encounter_monster).destroy_all

        encounter = Encounter.create!(campaign: campaign, name: 'Dragon Encounter')
        dragon_encounter = EncounterMonster.create!(
          encounter: encounter,
          monster: young_dragon,
          current_hit_points: 178,
          max_hit_points: 178
        )

        CombatParticipant.create!(
          combat: combat,
          encounter_monster: dragon_encounter,
          initiative: 15,
          current_hit_points: 0, # Defeated
          max_hit_points: 178,
          armor_class: 18
        )
      end

      it 'generates substantial treasure for high CR enemy' do
        initial_gold = character.gold

        result = executor.execute('end_combat', {
          outcome: 'victory'
        })

        expect(result[:treasure][:total_cr]).to eq(10)
        treasure_data = result[:treasure][:treasure]

        # High CR should generate significant treasure
        expect(treasure_data[:total_gold_value]).to be > 100

        character.reload
        gold_gained = character.gold - initial_gold
        expect(gold_gained).to be > 100
      end
    end

    context 'treasure generation failure handling' do
      before do
        # Mock Treasure::Generator to raise an error
        allow(Treasure::Generator).to receive(:generate_by_challenge_rating)
          .and_raise(StandardError.new('Treasure generation failed'))
      end

      it 'handles errors gracefully and continues combat end' do
        result = executor.execute('end_combat', {
          outcome: 'victory'
        })

        # Combat should still end successfully even if treasure fails
        expect(result[:success]).to be true
        expect(result[:combat_id]).to be_present
        expect(result[:treasure]).to be_nil
      end
    end
  end
end
