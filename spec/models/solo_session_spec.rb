# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SoloSession, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:campaign) }
    it { should belong_to(:character) }
    it { should belong_to(:adventure_template).optional: true }
    it { should belong_to(:combat).optional: true }
    it { should have_one(:latest_game_state) }
    it { should have_many(:solo_game_states).dependent(:destroy) }
    it { should have_many(:ai_conversations).dependent(:destroy) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.active).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.in_progress' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.in_progress).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.user_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.user_id_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.user_id_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.user_id_max).to be_an(ActiveRecord::Relation)
      end
    end

  end

end