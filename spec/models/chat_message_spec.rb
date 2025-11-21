# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatMessage, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:game_session) }
    it { should belong_to(:recipient).optional: true }
    it { should belong_to(:character).optional: true }
    it { should have_many(:reactions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
  end

  describe 'scopes' do
    describe '.public_messages' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.public_messages).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_user' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_user).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.before' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.before).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.search' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.search).to be_an(ActiveRecord::Relation)
      end
    end

  end

end