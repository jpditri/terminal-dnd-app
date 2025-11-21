# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DungeonTemplate, type: :model do
  describe 'associations' do
    it { should belong_to(:created_by_user) }
    it { should have_many(:generated_dungeons).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:min_party_level) }
    it { should validate_numericality_of(:max_party_level) }
    it { should validate_numericality_of(:room_count_min) }
    it { should validate_numericality_of(:room_count_max) }
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

    describe '.min_party_level_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.min_party_level_min).to be_an(ActiveRecord::Relation)
      end
    end

  end

end