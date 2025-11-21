# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe 'associations' do
    it { should belong_to(:world).optional: true }
    it { should belong_to(:dm).optional: true }
    it { should belong_to(:template).optional: true }
    it { should have_one(:ai_dm_assistant).dependent(:destroy) }
    it { should have_many(:campaign_memberships).dependent(:destroy) }
    it { should have_many(:members).through(:campaign_memberships) }
    it { should have_many(:characters).dependent(:destroy) }
    it { should have_many(:game_sessions).dependent(:destroy) }
    it { should have_many(:campaign_notes).dependent(:destroy) }
    it { should have_many(:solo_sessions).dependent(:destroy) }
    it { should have_many(:quest_logs).dependent(:destroy) }
    it { should have_many(:maps).dependent(:destroy) }
    it { should have_many(:encounters).dependent(:destroy) }
    it { should have_many(:npcs).dependent(:destroy) }
    it { should have_many(:combats).through(:game_sessions) }
    it { should have_many(:campaign_join_requests).dependent(:destroy) }
    it { should have_many(:campaign_ratings).dependent(:destroy) }
    it { should have_many(:export_archives).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
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

    describe '.search_name' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.search_name).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.search_description' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.search_description).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.public_campaigns' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.public_campaigns).to be_an(ActiveRecord::Relation)
      end
    end

  end

end