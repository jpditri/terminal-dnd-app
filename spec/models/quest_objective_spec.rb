# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestObjective, type: :model do
  describe 'associations' do
    it { should belong_to(:quest_log) }
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

    describe '.quest_log_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.quest_log_id_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.quest_log_id_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.quest_log_id_max).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.quest_log_id_range' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.quest_log_id_range).to be_an(ActiveRecord::Relation)
      end
    end

  end

end