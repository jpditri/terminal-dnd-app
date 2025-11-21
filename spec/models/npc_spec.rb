# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Npc, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign) }
    it { should belong_to(:world).optional: true }
    it { should belong_to(:faction).optional: true }
    it { should belong_to(:location).optional: true }
    it { should belong_to(:race).optional: true }
    it { should belong_to(:character_class).optional: true }
    it { should belong_to(:alignment).optional: true }
    it { should have_many(:npc_interactions).dependent(:destroy) }
    it { should have_many(:faction_memberships).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:age) }
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