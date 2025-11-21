# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestLog, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign).optional: true }
    it { should belong_to(:character).optional: true }
    it { should belong_to(:template).optional: true }
    it { should belong_to(:parent_quest).optional: true }
    it { should have_many(:quest_objectives).dependent(:destroy) }
    it { should have_many(:child_quests).dependent(:nullify) }
    it { should have_many(:quests_in_chain) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
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

    describe '.campaign_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.campaign_id_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.campaign_id_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.campaign_id_max).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.campaign_id_range' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.campaign_id_range).to be_an(ActiveRecord::Relation)
      end
    end

  end

end