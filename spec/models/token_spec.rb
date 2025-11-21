# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Token, type: :model do
  describe 'associations' do
    it { should belong_to(:map) }
    it { should belong_to(:character).optional: true }
    it { should belong_to(:encounter_monster).optional: true }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:grid_x) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.map_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.map_id_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.map_id_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.map_id_max).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.map_id_range' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.map_id_range).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.character_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.character_id_min).to be_an(ActiveRecord::Relation)
      end
    end

  end

end