# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealingLog, type: :model do
  describe 'associations' do
    it { should belong_to(:combat_encounter) }
    it { should belong_to(:source).optional: true }
    it { should belong_to(:target).optional: true }
  end

  describe 'scopes' do
    describe '.by_round' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_round).to be_an(ActiveRecord::Relation)
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