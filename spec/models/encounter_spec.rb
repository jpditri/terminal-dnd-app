# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Encounter, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign).optional: true }
    it { should belong_to(:game_session).optional: true }
    it { should have_many(:encounter_monsters).dependent(:destroy) }
    it { should have_many(:monsters).through(:encounter_monsters) }
    it { should have_many(:combats).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.active).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.campaign_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.campaign_id_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.campaign_id_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.campaign_id_max).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.campaign_id_range' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.campaign_id_range).to be_an(ActiveRecord::Relation)
      end
    end

  end

end