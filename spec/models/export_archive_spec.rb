# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportArchive, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:archive_type) }
    it { should validate_presence_of(:status) }
    it { should validate_uniqueness_of(:download_token) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.active).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.completed' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.completed).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.failed' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.failed).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.expired' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.expired).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.not_expired' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.not_expired).to be_an(ActiveRecord::Relation)
      end
    end

  end

end