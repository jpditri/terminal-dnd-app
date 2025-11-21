# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameSession, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign) }
    it { should belong_to(:current_turn_player).optional: true }
    it { should have_one(:ai_dm_context).dependent(:destroy) }
    it { should have_many(:game_session_participants).dependent(:destroy) }
    it { should have_many(:characters).through(:game_session_participants) }
    it { should have_many(:users).through(:game_session_participants) }
    it { should have_many(:session_recaps).dependent(:destroy) }
    it { should have_many(:combats).dependent(:destroy) }
    it { should have_many(:dice_rolls).dependent(:destroy) }
    it { should have_many(:chat_messages).dependent(:destroy) }
    it { should have_many(:ai_dm_suggestions).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.active).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.in_progress' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.in_progress).to be_an(ActiveRecord::Relation)
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

  end

end