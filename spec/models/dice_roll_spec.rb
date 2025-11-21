# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiceRoll, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:character).optional: true }
    it { should belong_to(:game_session).optional: true }
    it { should belong_to(:combat).optional: true }
    it { should belong_to(:combat_action).optional: true }
    it { should belong_to(:dm_approver).optional: true }
    it { should belong_to(:original_roll).optional: true }
    it { should belong_to(:superseded_by_roll).optional: true }
    it { should have_many(:rerolls).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:roll_type) }
    it { should validate_presence_of(:total) }
    it { should validate_presence_of(:results) }
    it { should validate_presence_of(:state) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.active).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.visible' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.visible).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.hidden_rolls' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.hidden_rolls).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_roll_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_roll_type).to be_an(ActiveRecord::Relation)
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