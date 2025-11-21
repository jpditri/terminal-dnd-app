# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionPresence, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:game_session) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:connection_count) }
  end

  describe 'scopes' do
    describe '.online' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.online).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.offline' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.offline).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.away' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.away).to be_an(ActiveRecord::Relation)
      end
    end

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

  end

end