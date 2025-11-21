# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomebrewItem, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:campaign).optional: true }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
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

    describe '.published_only' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.published_only).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_type).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_visibility' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_visibility).to be_an(ActiveRecord::Relation)
      end
    end

  end

end