# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeneratedTreasure, type: :model do
  describe 'associations' do
    it { should belong_to(:loot_table) }
    it { should belong_to(:campaign).optional: true }
    it { should belong_to(:character).optional: true }
  end

  describe 'validations' do
    it { should validate_presence_of(:generated_at) }
    it { should validate_presence_of(:treasure_data) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_campaign' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_campaign).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_character' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_character).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.this_week' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.this_week).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.this_month' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.this_month).to be_an(ActiveRecord::Relation)
      end
    end

  end

end