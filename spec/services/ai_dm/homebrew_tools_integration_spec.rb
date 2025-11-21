# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AI DM Homebrew Tools Integration', type: :integration do
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

  describe 'create_homebrew_item tool' do
    let(:item_params) do
      {
        name: 'Flaming Longsword',
        description: 'A beautifully crafted longsword with flames dancing along its blade. Forged in the heart of a volcano.',
        rarity: 'rare',
        item_type: 'weapon',
        requires_attunement: true,
        properties: {
          attack_bonus: 1,
          damage_bonus: 2,
          damage_dice: '1d8',
          damage_type: 'slashing',
          spell_effects: [
            {
              spell_name: 'Burning Hands',
              level: 1,
              uses: 3,
              recharge: 'dawn'
            }
          ]
        },
        cursed: false,
        grant_to_character: true
      }
    end

    it 'creates a homebrew item successfully' do
      result = executor.execute('create_homebrew_item', item_params)

      expect(result[:success]).to be true
      expect(result[:message]).to include('Created homebrew item')
      expect(result[:homebrew_item_id]).to be_present

      homebrew_item = HomebrewItem.find(result[:homebrew_item_id])
      expect(homebrew_item.name).to eq('Flaming Longsword')
      expect(homebrew_item.rarity).to eq('rare')
      expect(homebrew_item.properties['attack_bonus']).to eq(1)
      expect(homebrew_item.approved).to be false
    end

    it 'validates item balance and provides warnings' do
      overpowered_item = item_params.merge(
        rarity: 'common',
        properties: {
          damage_bonus: 5,
          ac_bonus: 3
        }
      )

      result = executor.execute('create_homebrew_item', overpowered_item)

      expect(result[:success]).to be true
      expect(result[:validation_warnings]).to be_present
      expect(result[:validation_warnings]).to include(match(/exceeds recommended maximum/))
    end

    it 'fails validation for invalid item data' do
      invalid_item = item_params.merge(
        rarity: 'super_legendary',
        item_type: 'gadget'
      )

      result = executor.execute('create_homebrew_item', invalid_item)

      expect(result[:success]).to be false
      expect(result[:error]).to include('validation failed')
    end

    it 'queues item for approval before granting' do
      result = executor.execute('create_homebrew_item', item_params)

      expect(result[:success]).to be true

      homebrew_item = HomebrewItem.find(result[:homebrew_item_id])
      expect(homebrew_item.pending_grant_character_id).to eq(character.id)

      # Item should not be in inventory until approved
      expect(character.inventory_items.count).to eq(0)
    end
  end

  describe 'generate_treasure tool' do
    context 'by challenge rating' do
      it 'generates treasure for CR 0-4' do
        result = executor.execute('generate_treasure', {
          method: 'challenge_rating',
          challenge_rating: 2,
          grant_to_character: true
        })

        expect(result[:success]).to be true
        expect(result[:message]).to include('Generated treasure')
        expect(result[:treasure]).to be_present

        treasure = result[:treasure]
        expect(treasure).to have_key(:total_gold_value)
        expect(treasure[:total_gold_value]).to be >= 0

        # Character should receive gold
        character.reload
        expect(character.gold).to be > 100 # Started with 100
      end

      it 'generates higher value treasure for higher CR' do
        cr5_result = executor.execute('generate_treasure', {
          method: 'challenge_rating',
          challenge_rating: 5,
          grant_to_character: false
        })

        cr15_result = executor.execute('generate_treasure', {
          method: 'challenge_rating',
          challenge_rating: 15,
          grant_to_character: false
        })

        expect(cr15_result[:treasure][:total_gold_value]).to be > cr5_result[:treasure][:total_gold_value]
      end
    end

    context 'from loot table' do
      let(:loot_table) do
        LootTable.create!(
          campaign: campaign,
          name: 'Goblin Loot',
          description: 'Standard loot from goblins'
        )
      end

      before do
        LootTableEntry.create!(
          loot_table: loot_table,
          treasure_type: 'gold',
          weight: 70,
          quantity_dice: '2d6'
        )
        LootTableEntry.create!(
          loot_table: loot_table,
          treasure_type: 'item',
          weight: 30,
          quantity_dice: '1',
          treasure_data: { item_name: 'Rusty Dagger' }
        )
      end

      it 'generates treasure from loot table' do
        result = executor.execute('generate_treasure', {
          method: 'loot_table',
          loot_table_id: loot_table.id,
          grant_to_character: true
        })

        expect(result[:success]).to be true
        expect(result[:treasure]).to be_present

        generated_treasure = GeneratedTreasure.last
        expect(generated_treasure.loot_table).to eq(loot_table)
        expect(generated_treasure.campaign).to eq(campaign)
      end
    end
  end

  describe 'create_loot_table tool' do
    it 'creates a loot table with entries' do
      result = executor.execute('create_loot_table', {
        name: 'Dragon Hoard',
        description: 'Treasure from an ancient dragon',
        entries: [
          {
            treasure_type: 'gold',
            weight: 50,
            quantity_dice: '10d100'
          },
          {
            treasure_type: 'item',
            weight: 30,
            quantity_dice: '1d3',
            treasure_data: { item_category: 'magic_weapon' }
          },
          {
            treasure_type: 'item',
            weight: 20,
            quantity_dice: '1',
            treasure_data: { item_category: 'magic_armor' }
          }
        ]
      })

      expect(result[:success]).to be true
      expect(result[:loot_table_id]).to be_present

      loot_table = LootTable.find(result[:loot_table_id])
      expect(loot_table.name).to eq('Dragon Hoard')
      expect(loot_table.loot_table_entries.count).to eq(3)
    end
  end

  describe 'item management tools' do
    let(:homebrew_item) do
      HomebrewItem.create!(
        campaign: campaign,
        creator: character,
        name: 'Ring of Testing',
        description: 'A magical ring for testing',
        rarity: 'uncommon',
        item_type: 'ring',
        requires_attunement: true,
        properties: { ac_bonus: 1 },
        approved: true
      )
    end

    describe 'grant_homebrew_item' do
      it 'adds homebrew item to character inventory' do
        result = executor.execute('grant_homebrew_item', {
          homebrew_item_id: homebrew_item.id,
          quantity: 1,
          identified: true
        })

        expect(result[:success]).to be true
        expect(result[:inventory_item_id]).to be_present

        character.reload
        expect(character.inventory_items.count).to eq(1)

        inventory_item = character.inventory_items.first
        expect(inventory_item.name).to eq('Ring of Testing')
        expect(inventory_item.identified).to be true
      end
    end

    describe 'attune_item' do
      let(:inventory_item) do
        InventoryItem.create!(
          character: character,
          homebrew_item: homebrew_item,
          name: homebrew_item.name,
          quantity: 1,
          properties: homebrew_item.properties.merge('requires_attunement' => true)
        )
      end

      it 'attunes character to item' do
        result = executor.execute('attune_item', {
          inventory_item_id: inventory_item.id
        })

        expect(result[:success]).to be true

        inventory_item.reload
        expect(inventory_item.attuned).to be true
      end

      it 'enforces 3-item attunement limit' do
        # Create 3 attuned items
        3.times do |i|
          InventoryItem.create!(
            character: character,
            name: "Attuned Item #{i}",
            quantity: 1,
            attuned: true,
            properties: { 'requires_attunement' => true }
          )
        end

        # Try to attune 4th item
        result = executor.execute('attune_item', {
          inventory_item_id: inventory_item.id
        })

        expect(result[:success]).to be false
        expect(result[:error]).to include('already has 3 attuned items')
      end

      it 'fails if item does not require attunement' do
        non_attunement_item = InventoryItem.create!(
          character: character,
          name: 'Potion of Healing',
          quantity: 1,
          properties: {}
        )

        result = executor.execute('attune_item', {
          inventory_item_id: non_attunement_item.id
        })

        expect(result[:success]).to be false
        expect(result[:error]).to include('does not require attunement')
      end
    end

    describe 'identify_item' do
      let(:unidentified_item) do
        InventoryItem.create!(
          character: character,
          name: 'Unknown Ring',
          quantity: 1,
          identified: false,
          properties: { damage_bonus: 2, rarity: 'rare' }
        )
      end

      it 'reveals item properties' do
        result = executor.execute('identify_item', {
          inventory_item_id: unidentified_item.id,
          method: 'spell'
        })

        expect(result[:success]).to be true
        expect(result[:properties]).to be_present

        unidentified_item.reload
        expect(unidentified_item.identified).to be true
      end
    end

    describe 'remove_item' do
      let(:inventory_item) do
        InventoryItem.create!(
          character: character,
          name: 'Rope',
          quantity: 5
        )
      end

      it 'removes entire stack' do
        result = executor.execute('remove_item', {
          inventory_item_id: inventory_item.id,
          quantity: 5,
          reason: 'Used for climbing'
        })

        expect(result[:success]).to be true

        expect(InventoryItem.exists?(inventory_item.id)).to be false
      end

      it 'reduces quantity for partial removal' do
        result = executor.execute('remove_item', {
          inventory_item_id: inventory_item.id,
          quantity: 2,
          reason: 'Sold to merchant'
        })

        expect(result[:success]).to be true

        inventory_item.reload
        expect(inventory_item.quantity).to eq(3)
      end
    end
  end

  describe 'create_homebrew_spell tool' do
    it 'creates a homebrew spell successfully' do
      result = executor.execute('create_homebrew_spell', {
        name: 'Test Bolt',
        description: 'A bolt of testing energy streaks toward a creature within range.',
        level: 2,
        school: 'evocation',
        casting_time: '1 action',
        range: '120 feet',
        components: %w[V S],
        duration: 'Instantaneous',
        damage_dice: '3d6',
        damage_type: 'force',
        available_to_classes: %w[wizard sorcerer]
      })

      expect(result[:success]).to be true
      expect(result[:homebrew_spell_id]).to be_present

      spell = HomebrewSpell.find(result[:homebrew_spell_id])
      expect(spell.name).to eq('Test Bolt')
      expect(spell.level).to eq(2)
      expect(spell.approved).to be false
    end
  end

  describe 'list_homebrew tool' do
    before do
      HomebrewItem.create!(
        campaign: campaign,
        creator: character,
        name: 'Item 1',
        description: 'Test item',
        rarity: 'common',
        item_type: 'weapon',
        approved: true
      )

      HomebrewSpell.create!(
        campaign: campaign,
        creator: character,
        name: 'Spell 1',
        description: 'Test spell',
        level: 1,
        school: 'evocation',
        casting_time: '1 action',
        range: '60 feet',
        components: ['V'],
        duration: 'Instantaneous',
        approved: true
      )
    end

    it 'lists all homebrew content' do
      result = executor.execute('list_homebrew', {
        content_type: 'all'
      })

      expect(result[:success]).to be true
      expect(result[:homebrew][:items].length).to eq(1)
      expect(result[:homebrew][:spells].length).to eq(1)
    end

    it 'filters by content type' do
      result = executor.execute('list_homebrew', {
        content_type: 'items'
      })

      expect(result[:success]).to be true
      expect(result[:homebrew][:items].length).to eq(1)
      expect(result[:homebrew][:spells]).to be_empty
    end
  end
end
