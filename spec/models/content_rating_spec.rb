# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentRating, type: :model do
  describe 'associations' do
    it { should belong_to(:shared_content) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:shared_content_id) }
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

    describe '.for_content' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_content).to be_an(ActiveRecord::Relation)
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