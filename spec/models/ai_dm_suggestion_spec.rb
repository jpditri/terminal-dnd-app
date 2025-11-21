# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiDmSuggestion, type: :model do
  describe 'associations' do
    it { should belong_to(:ai_dm_assistant) }
    it { should belong_to(:game_session).optional: true }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:suggestion_type) }
    it { should validate_presence_of(:content) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.accepted' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.accepted).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_type).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_session' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_session).to be_an(ActiveRecord::Relation)
      end
    end

  end

end