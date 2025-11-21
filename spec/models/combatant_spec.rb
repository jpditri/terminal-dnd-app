# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Combatant, type: :model do
  describe 'associations' do
    it { should belong_to(:combat_encounter) }
    it { should belong_to(:character).optional: true }
    it { should have_many(:active_effects).dependent(:destroy) }
    it { should have_many(:damage_logs_as_source) }
    it { should have_many(:damage_logs_as_target) }
    it { should have_many(:healing_logs_as_source) }
    it { should have_many(:healing_logs_as_target) }
  end

  describe 'scopes' do
    describe '.pcs' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.pcs).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.npcs' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.npcs).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.conscious' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.conscious).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.unconscious' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.unconscious).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.stable' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.stable).to be_an(ActiveRecord::Relation)
      end
    end

  end

end