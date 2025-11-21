# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CombatEncounter, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign) }
    it { should belong_to(:game_session).optional: true }
    it { should belong_to(:current_turn_combatant).optional: true }
    it { should have_many(:combatants).dependent(:destroy) }
    it { should have_many(:damage_logs).dependent(:destroy) }
    it { should have_many(:healing_logs).dependent(:destroy) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.active).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.preparing' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.preparing).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.completed' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.completed).to be_an(ActiveRecord::Relation)
      end
    end

  end

end