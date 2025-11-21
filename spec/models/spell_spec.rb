# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spell, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.search_name' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.search_name).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.level_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.level_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.level_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.level_max).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.level_range' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.level_range).to be_an(ActiveRecord::Relation)
      end
    end

  end

end