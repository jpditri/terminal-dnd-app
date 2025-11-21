# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Treasure::DiceParser do
  describe '.roll' do
    it 'rolls a simple dice expression' do
      result = described_class.roll('2d6')

      expect(result[:total]).to be_between(2, 12)
      expect(result[:rolls].length).to eq(2)
      expect(result[:rolls]).to all(be_between(1, 6))
      expect(result[:modifier]).to eq(0)
      expect(result[:expression]).to eq('2d6')
    end

    it 'rolls dice with positive modifier' do
      result = described_class.roll('1d20+5')

      expect(result[:total]).to be_between(6, 25)
      expect(result[:rolls].length).to eq(1)
      expect(result[:modifier]).to eq(5)
    end

    it 'rolls dice with negative modifier' do
      result = described_class.roll('2d6-2')

      expect(result[:total]).to be_between(0, 10)
      expect(result[:modifier]).to eq(-2)
    end

    it 'handles single die notation without count' do
      result = described_class.roll('d20')

      expect(result[:total]).to be_between(1, 20)
      expect(result[:rolls].length).to eq(1)
    end

    it 'includes breakdown in result' do
      result = described_class.roll('2d6+3')

      expect(result[:breakdown]).to be_a(String)
      expect(result[:breakdown]).to include('+3')
    end
  end

  describe 'validation' do
    it 'raises error for invalid dice expression' do
      expect {
        described_class.roll('invalid')
      }.to raise_error(Treasure::DiceParser::InvalidDiceExpression, /Invalid dice expression/)
    end

    it 'raises error for zero dice count' do
      expect {
        described_class.roll('0d6')
      }.to raise_error(Treasure::DiceParser::InvalidDiceExpression, /Dice count must be positive/)
    end

    it 'raises error for dice with less than 2 sides' do
      expect {
        described_class.roll('2d1')
      }.to raise_error(Treasure::DiceParser::InvalidDiceExpression, /must have at least 2 sides/)
    end

    it 'raises error for too many dice' do
      expect {
        described_class.roll('101d6')
      }.to raise_error(Treasure::DiceParser::InvalidDiceExpression, /Cannot roll more than 100 dice/)
    end

    it 'raises error for dice with too many sides' do
      expect {
        described_class.roll('1d101')
      }.to raise_error(Treasure::DiceParser::InvalidDiceExpression, /cannot have more than 100 sides/)
    end
  end

  describe 'common D&D dice expressions' do
    it 'handles d4 (dagger damage)' do
      result = described_class.roll('1d4')
      expect(result[:total]).to be_between(1, 4)
    end

    it 'handles d6 (shortsword damage)' do
      result = described_class.roll('1d6')
      expect(result[:total]).to be_between(1, 6)
    end

    it 'handles d8 (longsword damage)' do
      result = described_class.roll('1d8')
      expect(result[:total]).to be_between(1, 8)
    end

    it 'handles d10 (pike damage)' do
      result = described_class.roll('1d10')
      expect(result[:total]).to be_between(1, 10)
    end

    it 'handles d12 (greataxe damage)' do
      result = described_class.roll('1d12')
      expect(result[:total]).to be_between(1, 12)
    end

    it 'handles d20 (ability checks)' do
      result = described_class.roll('1d20')
      expect(result[:total]).to be_between(1, 20)
    end

    it 'handles d100 (percentile rolls)' do
      result = described_class.roll('1d100')
      expect(result[:total]).to be_between(1, 100)
    end

    it 'handles fireball damage (8d6)' do
      result = described_class.roll('8d6')
      expect(result[:total]).to be_between(8, 48)
      expect(result[:rolls].length).to eq(8)
    end
  end
end
