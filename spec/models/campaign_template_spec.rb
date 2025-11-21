# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignTemplate, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:template_ratings).dependent(:destroy) }
    it { should have_many(:campaigns).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:visibility) }
    it { should validate_presence_of(:template_data) }
    it { should validate_numericality_of(:use_count) }
  end

  describe 'scopes' do
    describe '.public_templates' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.public_templates).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.unlisted_templates' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.unlisted_templates).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.private_templates' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.private_templates).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_category' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_category).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_level_range' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_level_range).to be_an(ActiveRecord::Relation)
      end
    end

  end

end