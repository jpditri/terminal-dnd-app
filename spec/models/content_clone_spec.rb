# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentClone, type: :model do
  describe 'associations' do
    it { should belong_to(:shared_content) }
    it { should belong_to(:user) }
    it { should belong_to(:cloned_content) }
  end

  describe 'validations' do
    it { should validate_presence_of(:shared_content_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:cloned_content_type) }
    it { should validate_presence_of(:cloned_content_id) }
  end

  describe 'scopes' do
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

    describe '.for_shared_content' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.for_shared_content).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_content_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_content_type).to be_an(ActiveRecord::Relation)
      end
    end

  end

end