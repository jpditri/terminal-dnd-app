# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LootTableEntry, type: :model do
  describe 'associations' do
    it { should belong_to(:loot_table) }
    it { should belong_to(:item).optional: true }
  end

  describe 'validations' do
    it { should validate_presence_of(:treasure_type) }
    it { should validate_numericality_of(:weight) }
  end

  describe 'scopes' do
    describe '.by_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_type).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.ordered_by_weight' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.ordered_by_weight).to be_an(ActiveRecord::Relation)
      end
    end

  end

end