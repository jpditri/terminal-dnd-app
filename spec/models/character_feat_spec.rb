# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterFeat, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
    it { should belong_to(:feat) }
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:character_id) }
    it { should validate_numericality_of(:level_gained) }
  end

  describe 'scopes' do
    describe '.by_level' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_level).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.at_level' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.at_level).to be_an(ActiveRecord::Relation)
      end
    end

  end

end