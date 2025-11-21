# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Background, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.search_name' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.search_name).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.search_description' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.search_description).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.search_all' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.search_all).to be_an(ActiveRecord::Relation)
      end
    end

  end

end