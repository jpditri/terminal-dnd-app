# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiDmOverride, type: :model do
  describe 'associations' do
    it { should belong_to(:ai_dm_assistant) }
    it { should belong_to(:ai_dm_suggestion) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:original_suggestion) }
    it { should validate_presence_of(:dm_override) }
    it { should validate_presence_of(:override_type) }
  end

  describe 'scopes' do
    describe '.recent' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.recent).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.by_type' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.by_type).to be_an(ActiveRecord::Relation)
      end
    end

  end

end