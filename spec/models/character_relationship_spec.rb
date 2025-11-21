# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterRelationship, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
    it { should belong_to(:related_character).optional: true }
  end

  describe 'validations' do
    it { should validate_presence_of(:relationship_type) }
    it { should validate_presence_of(:bond_strength) }
    it { should validate_uniqueness_of(:related_character_id) }
  end

  describe 'scopes' do
    describe '.pc_relationships' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.pc_relationships).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.npc_relationships' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.npc_relationships).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.strong_bonds' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.strong_bonds).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.weak_bonds' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.weak_bonds).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_strength' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_strength).to be_an(ActiveRecord::Relation)
      end
    end

  end

end