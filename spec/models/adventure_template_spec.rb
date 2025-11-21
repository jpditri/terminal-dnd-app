# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdventureTemplate, type: :model do
  describe 'associations' do
    it { should belong_to(:author) }
    it { should have_many(:template_ratings).dependent(:destroy) }
    it { should have_many(:solo_sessions).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:creator_id) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:difficulty) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:min_level) }
    it { should validate_presence_of(:max_level) }
    it { should validate_presence_of(:estimated_duration) }
    it { should validate_numericality_of(:usage_count) }
    it { should validate_presence_of(:template_data) }
  end

  describe 'scopes' do
    describe '.published' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.published).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.draft' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.draft).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.popular' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.popular).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.public_templates' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.public_templates).to be_an(ActiveRecord::Relation)
      end
    end

  end

end