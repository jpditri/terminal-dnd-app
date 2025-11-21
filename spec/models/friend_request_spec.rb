# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendRequest, type: :model do
  describe 'associations' do
    it { should belong_to(:sender) }
    it { should belong_to(:receiver) }
  end

  describe 'validations' do
    it { should validate_presence_of(:sender_id) }
    it { should validate_presence_of(:receiver_id) }
    it { should validate_presence_of(:status) }
  end

  describe 'scopes' do
    describe '.pending' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.pending).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.accepted' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.accepted).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.declined' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.declined).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_user' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_user).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.sent_by' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.sent_by).to be_an(ActiveRecord::Relation)
      end
    end

  end

end