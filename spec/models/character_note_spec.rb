# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterNote, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:note_category) }
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

    describe '.character_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.character_id_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.character_id_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.character_id_max).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.character_id_range' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.character_id_range).to be_an(ActiveRecord::Relation)
      end
    end

  end

end