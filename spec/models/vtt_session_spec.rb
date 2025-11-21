# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VttSession, type: :model do
  describe 'associations' do
    it { should belong_to(:game_session) }
    it { should belong_to(:campaign) }
    it { should belong_to(:location).optional: true }
    it { should belong_to(:encounter).optional: true }
    it { should have_one(:vtt_map).dependent(:destroy) }
    it { should have_many(:vtt_tokens).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:grid_size) }
    it { should validate_numericality_of(:zoom_level) }
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

  end

end