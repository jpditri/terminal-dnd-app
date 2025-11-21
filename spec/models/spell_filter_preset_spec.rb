# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpellFilterPreset, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional: true }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:filter_data) }
  end

  describe 'scopes' do
    describe '.custom' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.custom).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.system_presets' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.system_presets).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.shared' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.shared).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.public_presets' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.public_presets).to be_an(ActiveRecord::Relation)
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