# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weapon, type: :model do
  describe 'associations' do
    it { should belong_to(:character).optional: true }
    it { should belong_to(:item).optional: true }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:damage_dice) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.active).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_damage_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_damage_type).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.finesse_weapons' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.finesse_weapons).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.versatile_weapons' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.versatile_weapons).to be_an(ActiveRecord::Relation)
      end
    end

  end

end