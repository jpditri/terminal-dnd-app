# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiContext, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
    it { should belong_to(:solo_session).optional: true }
  end

  describe 'validations' do
    it { should validate_presence_of(:character_id) }
    it { should validate_numericality_of(:context_version) }
  end

  describe 'scopes' do
    describe '.for_character' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_character).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.active' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.active).to be_an(ActiveRecord::Relation)
      end
    end

  end

end