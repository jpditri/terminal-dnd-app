# frozen_string_literal: true

require 'rails_helper'

RSpec.describe World, type: :model do
  describe 'associations' do
    it { should belong_to(:creator).optional: true }
    it { should have_many(:campaigns).dependent(:destroy) }
    it { should have_many(:world_lore_entries).dependent(:destroy) }
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

    describe '.creator_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.creator_id_min).to be_an(ActiveRecord::Relation)
      end
    end

  end

end