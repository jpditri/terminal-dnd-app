# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignRating, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:campaign_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:rating) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_campaign' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_campaign).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_user' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_user).to be_an(ActiveRecord::Relation)
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

  end

end