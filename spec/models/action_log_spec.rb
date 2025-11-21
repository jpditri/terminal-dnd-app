# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionLog, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:game_session) }
  end

  describe 'validations' do
    it { should validate_presence_of(:action_type) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_type).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_session' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_session).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.since' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.since).to be_an(ActiveRecord::Relation)
      end
    end

  end

end