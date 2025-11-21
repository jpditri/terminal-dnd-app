# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterAiAssistant, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
  end

  describe 'validations' do
    it { should validate_presence_of(:character_id) }
    it { should validate_numericality_of(:ai_usage_tokens) }
  end

  describe 'scopes' do
    describe '.enabled' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.enabled).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.over_limit' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.over_limit).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.under_limit' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.under_limit).to be_an(ActiveRecord::Relation)
      end
    end

  end

end