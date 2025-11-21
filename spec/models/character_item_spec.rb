# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterItem, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
    it { should belong_to(:item) }
  end

  describe 'validations' do
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

    describe '.in_slot' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.in_slot).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.equipped_in_slots' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.equipped_in_slots).to be_an(ActiveRecord::Relation)
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