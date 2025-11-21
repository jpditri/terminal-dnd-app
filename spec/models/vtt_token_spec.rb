# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VttToken, type: :model do
  describe 'associations' do
    it { should belong_to(:vtt_session) }
    it { should belong_to(:character).optional: true }
    it { should belong_to(:npc).optional: true }
    it { should belong_to(:monster).optional: true }
  end

  describe 'validations' do
    it { should validate_numericality_of(:rotation) }
    it { should validate_numericality_of(:x) }
  end

  describe 'scopes' do
    describe '.visible' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.visible).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.hidden_tokens' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.hidden_tokens).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.player_tokens' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.player_tokens).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.npc_tokens' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.npc_tokens).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.defeated' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.defeated).to be_an(ActiveRecord::Relation)
      end
    end

  end

end