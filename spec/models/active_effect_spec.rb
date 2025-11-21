# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveEffect, type: :model do
  describe 'associations' do
    it { should belong_to(:combatant) }
  end

  describe 'scopes' do
    describe '.conditions' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.conditions).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.buffs' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.buffs).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.debuffs' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.debuffs).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.concentration' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.concentration).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.regeneration' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.regeneration).to be_an(ActiveRecord::Relation)
      end
    end

  end

end