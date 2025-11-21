# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameSessionParticipant, type: :model do
  describe 'associations' do
    it { should belong_to(:game_session) }
    it { should belong_to(:user) }
    it { should belong_to(:character).optional: true }
  end

  describe 'validations' do
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

    describe '.pending_invitations' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.pending_invitations).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.accepted' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.accepted).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.declined' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.declined).to be_an(ActiveRecord::Relation)
      end
    end

  end

end