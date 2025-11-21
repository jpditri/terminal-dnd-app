# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignJoinRequest, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:campaign_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:status) }
  end

  describe 'scopes' do
    describe '.pending' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.pending).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.approved' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.approved).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.declined' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.declined).to be_an(ActiveRecord::Relation)
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

  end

end