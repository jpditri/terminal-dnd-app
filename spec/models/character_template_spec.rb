# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterTemplate, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:template_type) }
    it { should validate_numericality_of(:min_level) }
    it { should validate_numericality_of(:max_level) }
  end

  describe 'scopes' do
    describe '.public_templates' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.public_templates).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.private_templates' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.private_templates).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_user' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_user).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_type).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_class' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_class).to be_an(ActiveRecord::Relation)
      end
    end

  end

end