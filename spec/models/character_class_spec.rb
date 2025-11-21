# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterClass, type: :model do
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

    describe '.hit_die_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.hit_die_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.hit_die_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.hit_die_max).to be_an(ActiveRecord::Relation)
      end
    end

  end

end