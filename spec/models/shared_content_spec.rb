# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SharedContent, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:content) }
    it { should have_many(:content_clones).dependent(:destroy) }
    it { should have_many(:content_ratings).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:content_type) }
    it { should validate_presence_of(:content_id) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:visibility) }
    it { should validate_presence_of(:license_type) }
    it { should validate_numericality_of(:view_count) }
    it { should validate_numericality_of(:clone_count) }
  end

  describe 'scopes' do
    describe '.public_content' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.public_content).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.unlisted_content' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.unlisted_content).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.private_content' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.private_content).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_content_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_content_type).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_license' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_license).to be_an(ActiveRecord::Relation)
      end
    end

  end

end