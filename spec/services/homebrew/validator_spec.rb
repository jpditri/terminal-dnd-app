# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Homebrew::Validator do
  let(:validator) { described_class.new }

  describe '#validate_item' do
    let(:valid_item_data) do
      {
        name: 'Sword of Testing',
        description: 'A magical sword used for testing purposes. It gleams with arcane energy.',
        rarity: 'rare',
        item_type: 'weapon',
        requires_attunement: true,
        properties: {
          damage_bonus: 2,
          damage_dice: '1d8',
          damage_type: 'slashing'
        }
      }
    end

    context 'with valid item data' do
      it 'returns true' do
        expect(validator.validate_item(valid_item_data)).to be true
      end

      it 'has no errors' do
        validator.validate_item(valid_item_data)
        expect(validator.errors).to be_empty
      end
    end

    context 'with missing required fields' do
      it 'fails when name is missing' do
        item_data = valid_item_data.except(:name)
        expect(validator.validate_item(item_data)).to be false
        expect(validator.errors).to include(/Missing required field: name/)
      end

      it 'fails when description is missing' do
        item_data = valid_item_data.except(:description)
        expect(validator.validate_item(item_data)).to be false
        expect(validator.errors).to include(/Missing required field: description/)
      end

      it 'fails when rarity is missing' do
        item_data = valid_item_data.except(:rarity)
        expect(validator.validate_item(item_data)).to be false
        expect(validator.errors).to include(/Missing required field: rarity/)
      end
    end

    context 'with invalid rarity' do
      it 'fails for invalid rarity value' do
        item_data = valid_item_data.merge(rarity: 'super_rare')
        expect(validator.validate_item(item_data)).to be false
        expect(validator.errors).to include(/Invalid rarity/)
      end
    end

    context 'with invalid item type' do
      it 'fails for invalid item type' do
        item_data = valid_item_data.merge(item_type: 'gadget')
        expect(validator.validate_item(item_data)).to be false
        expect(validator.errors).to include(/Invalid item type/)
      end
    end

    context 'balance validation' do
      it 'warns when damage bonus exceeds rarity guidelines' do
        item_data = valid_item_data.merge(
          rarity: 'uncommon',
          properties: { damage_bonus: 5 }
        )
        validator.validate_item(item_data)
        expect(validator.warnings).to include(/Damage bonus.*exceeds recommended maximum/)
      end

      it 'warns when AC bonus exceeds rarity guidelines' do
        item_data = valid_item_data.merge(
          rarity: 'common',
          item_type: 'armor',
          properties: { ac_bonus: 3 }
        )
        validator.validate_item(item_data)
        expect(validator.warnings).to include(/AC bonus.*exceeds recommended maximum/)
      end

      it 'warns when ability bonus exceeds rarity guidelines' do
        item_data = valid_item_data.merge(
          rarity: 'rare',
          properties: { ability_bonuses: { strength: 5 } }
        )
        validator.validate_item(item_data)
        expect(validator.warnings).to include(/strength bonus.*exceeds recommended maximum/)
      end

      it 'warns when spell level exceeds rarity guidelines' do
        item_data = valid_item_data.merge(
          rarity: 'uncommon',
          properties: {
            spell_effects: [
              { spell_name: 'Fireball', level: 5 }
            ]
          }
        )
        validator.validate_item(item_data)
        expect(validator.warnings).to include(/Spell level 5 exceeds recommended maximum/)
      end
    end

    context 'with invalid damage dice' do
      it 'fails for malformed dice expression' do
        item_data = valid_item_data.merge(
          properties: { damage_dice: 'not-a-dice' }
        )
        expect(validator.validate_item(item_data)).to be false
        expect(validator.errors).to include(/Invalid damage dice format/)
      end
    end

    context 'with invalid damage type' do
      it 'fails for invalid damage type' do
        item_data = valid_item_data.merge(
          properties: { damage_type: 'tickle' }
        )
        expect(validator.validate_item(item_data)).to be false
        expect(validator.errors).to include(/Invalid damage type/)
      end
    end

    context 'attunement validation' do
      it 'warns when rare item does not require attunement' do
        item_data = valid_item_data.merge(requires_attunement: false, rarity: 'rare')
        validator.validate_item(item_data)
        expect(validator.warnings).to include(/typically require attunement/)
      end

      it 'validates attunement requirements' do
        item_data = valid_item_data.merge(
          requires_attunement: true,
          attunement_requirements: { alignment: 'chaotic_good' }
        )
        expect(validator.validate_item(item_data)).to be true
      end
    end

    context 'description validation' do
      it 'warns for very short descriptions' do
        item_data = valid_item_data.merge(description: 'Short')
        validator.validate_item(item_data)
        expect(validator.warnings).to include(/Description is very short/)
      end

      it 'warns for very long descriptions' do
        long_desc = 'a' * 5001
        item_data = valid_item_data.merge(description: long_desc)
        validator.validate_item(item_data)
        expect(validator.warnings).to include(/Description is very long/)
      end
    end
  end

  describe '#validate_spell' do
    let(:valid_spell_data) do
      {
        name: 'Test Bolt',
        description: 'A bolt of magical testing energy streaks toward a creature within range.',
        level: 2,
        school: 'evocation',
        casting_time: '1 action',
        range: '120 feet',
        components: %w[V S],
        duration: 'Instantaneous'
      }
    end

    context 'with valid spell data' do
      it 'returns true' do
        expect(validator.validate_spell(valid_spell_data)).to be true
      end

      it 'has no errors' do
        validator.validate_spell(valid_spell_data)
        expect(validator.errors).to be_empty
      end
    end

    context 'with missing required fields' do
      it 'fails when level is missing' do
        spell_data = valid_spell_data.except(:level)
        expect(validator.validate_spell(spell_data)).to be false
        expect(validator.errors).to include(/Missing required spell field: level/)
      end

      it 'fails when school is missing' do
        spell_data = valid_spell_data.except(:school)
        expect(validator.validate_spell(spell_data)).to be false
        expect(validator.errors).to include(/Missing required spell field: school/)
      end
    end

    context 'with invalid spell level' do
      it 'fails for negative level' do
        spell_data = valid_spell_data.merge(level: -1)
        expect(validator.validate_spell(spell_data)).to be false
        expect(validator.errors).to include(/Invalid spell level/)
      end

      it 'fails for level above 9' do
        spell_data = valid_spell_data.merge(level: 10)
        expect(validator.validate_spell(spell_data)).to be false
        expect(validator.errors).to include(/Invalid spell level/)
      end

      it 'accepts cantrips (level 0)' do
        spell_data = valid_spell_data.merge(level: 0)
        expect(validator.validate_spell(spell_data)).to be true
      end
    end

    context 'with invalid school' do
      it 'fails for invalid school' do
        spell_data = valid_spell_data.merge(school: 'pyromancy')
        expect(validator.validate_spell(spell_data)).to be false
        expect(validator.errors).to include(/Invalid spell school/)
      end

      it 'accepts all valid schools' do
        schools = %w[abjuration conjuration divination enchantment evocation illusion necromancy transmutation]
        schools.each do |school|
          spell_data = valid_spell_data.merge(school: school)
          expect(validator.validate_spell(spell_data)).to be true
        end
      end
    end

    context 'with invalid components' do
      it 'fails for invalid component' do
        spell_data = valid_spell_data.merge(components: ['X'])
        expect(validator.validate_spell(spell_data)).to be false
        expect(validator.errors).to include(/Invalid spell component/)
      end

      it 'accepts V, S, M components' do
        spell_data = valid_spell_data.merge(components: %w[V S M])
        expect(validator.validate_spell(spell_data)).to be true
      end
    end

    context 'range validation' do
      it 'warns for unusual ranges' do
        spell_data = valid_spell_data.merge(range: 'weird distance')
        validator.validate_spell(spell_data)
        expect(validator.warnings).to include(/Unusual spell range/)
      end

      it 'accepts standard ranges' do
        standard_ranges = ['Self', 'Touch', '30 feet', '1 mile', 'Sight', 'Unlimited']
        standard_ranges.each do |range|
          spell_data = valid_spell_data.merge(range: range)
          validator.validate_spell(spell_data)
          expect(validator.warnings).to be_empty
        end
      end
    end

    context 'duration validation' do
      it 'warns for unusual durations' do
        spell_data = valid_spell_data.merge(duration: 'weird time')
        validator.validate_spell(spell_data)
        expect(validator.warnings).to include(/Unusual spell duration/)
      end

      it 'accepts standard durations' do
        standard_durations = [
          'Instantaneous',
          '1 minute',
          'Concentration, up to 1 hour',
          'Until dispelled',
          'Special'
        ]
        standard_durations.each do |duration|
          spell_data = valid_spell_data.merge(duration: duration)
          validator.validate_spell(spell_data)
          expect(validator.warnings).to be_empty
        end
      end
    end
  end

  describe '#validation_result' do
    it 'returns validation summary' do
      validator.validate_item({
        name: 'Test Item',
        description: 'Test',
        rarity: 'common',
        item_type: 'weapon'
      })

      result = validator.validation_result
      expect(result).to have_key(:valid)
      expect(result).to have_key(:errors)
      expect(result).to have_key(:warnings)
      expect(result).to have_key(:message)
    end

    it 'includes appropriate message for valid item' do
      validator.validate_item({
        name: 'Test Item',
        description: 'A well-balanced test item for validation purposes.',
        rarity: 'common',
        item_type: 'weapon'
      })

      result = validator.validation_result
      expect(result[:message]).to include('successfully')
    end

    it 'includes error count in message for invalid item' do
      validator.validate_item({ name: '' })

      result = validator.validation_result
      expect(result[:message]).to include('failed')
      expect(result[:message]).to match(/\d+ errors/)
    end
  end
end
