# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBlock, type: :model do
  describe 'associations' do
    it { should belong_to(:blocker) }
    it { should belong_to(:blocked) }
  end

  describe 'validations' do
    it { should validate_presence_of(:blocker_id) }
    it { should validate_presence_of(:blocked_id) }
  end

  describe 'scopes' do
    describe '.for_blocker' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_blocker).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_blocked' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_blocked).to be_an(ActiveRecord::Relation)
      end
    end

  end

end