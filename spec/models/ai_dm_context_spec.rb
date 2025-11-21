# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiDmContext, type: :model do
  describe 'associations' do
    it { should belong_to(:ai_dm_assistant) }
    it { should belong_to(:game_session) }
  end

  describe 'validations' do
    it { should validate_presence_of(:ai_dm_assistant_id) }
    it { should validate_presence_of(:game_session_id) }
  end

  describe 'scopes' do
    describe '.active_session' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.active_session).to be_an(ActiveRecord::Relation)
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