# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feat, type: :model do
  describe 'associations' do
    it { should have_many(:character_feats).dependent(:destroy) }
    it { should have_many(:characters).through(:character_feats) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:source) }
  end

  describe 'scopes' do
    describe '.srd' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.srd).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.alphabetical' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.alphabetical).to be_an(ActiveRecord::Relation)
      end
    end

  end

end