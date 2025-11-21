# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Monster, type: :model do
  describe 'associations' do
    it { should belong_to(:alignment).optional: true }
    it { should have_many(:monster_abilities).dependent(:destroy) }
    it { should have_many(:encounter_monsters).dependent(:destroy) }
    it { should have_many(:encounters).through(:encounter_monsters) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
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

    describe '.alignment_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.alignment_id_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.alignment_id_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.alignment_id_max).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.alignment_id_range' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.alignment_id_range).to be_an(ActiveRecord::Relation)
      end
    end

  end

end