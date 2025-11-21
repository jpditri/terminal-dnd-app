# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestTemplate, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
    describe '.by_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_type).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_difficulty' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_difficulty).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_category' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_category).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_party_level' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_party_level).to be_an(ActiveRecord::Relation)
      end
    end

  end

end