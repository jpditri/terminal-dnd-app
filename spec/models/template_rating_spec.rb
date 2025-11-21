# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TemplateRating, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign_template).optional: true }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:rating) }
    it { should validate_numericality_of(:helpful_count) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_template' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_template).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.high_rated' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.high_rated).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.with_reviews' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.with_reviews).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.most_helpful' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.most_helpful).to be_an(ActiveRecord::Relation)
      end
    end

  end

end