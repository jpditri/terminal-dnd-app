# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:notifiable).optional: true }
  end

  describe 'validations' do
    it { should validate_presence_of(:notification_type) }
    it { should validate_presence_of(:priority) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:message) }
  end

  describe 'scopes' do
    describe '.unread' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.unread).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.read' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.read).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.for_user' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_user).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_priority' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_priority).to be_an(ActiveRecord::Relation)
      end
    end

  end

end