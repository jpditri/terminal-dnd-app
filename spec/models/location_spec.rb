# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'associations' do
    it { should belong_to(:world) }
    it { should belong_to(:parent_location).optional: true }
    it { should have_many(:child_locations).dependent(:nullify) }
    it { should have_many(:npcs).dependent(:nullify) }
    it { should have_many(:encounters).dependent(:nullify) }
    it { should have_many(:factions).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:danger_level) }
    it { should validate_numericality_of(:population) }
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

    describe '.world_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.world_id_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.world_id_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.world_id_max).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.world_id_range' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.world_id_range).to be_an(ActiveRecord::Relation)
      end
    end

  end

end