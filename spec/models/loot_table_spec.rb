# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LootTable, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional: true }
    it { should have_many(:loot_table_entries).dependent(:destroy) }
    it { should have_many(:generated_treasures).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
    describe '.srd' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.srd).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.homebrew' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.homebrew).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_type).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_challenge_rating' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_challenge_rating).to be_an(ActiveRecord::Relation)
      end
    end

  end

end