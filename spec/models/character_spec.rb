# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Character, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:campaign).optional: true }
    it { should belong_to(:race).optional: true }
    it { should belong_to(:character_class).optional: true }
    it { should belong_to(:background).optional: true }
    it { should have_one(:character_inventory).dependent(:destroy) }
    it { should have_one(:character_spell_manager).dependent(:destroy) }
    it { should have_one(:ai_assistant).dependent(:destroy) }
    it { should have_one(:ai_context).dependent(:destroy) }
    it { should have_one(:character_progression).dependent(:destroy) }
    it { should have_one(:character_combat_tracker).dependent(:destroy) }
    it { should have_many(:character_spells).dependent(:destroy) }
    it { should have_many(:spells).through(:character_spells) }
    it { should have_many(:character_items).dependent(:destroy) }
    it { should have_many(:items).through(:character_items) }
    it { should have_many(:character_feats).dependent(:destroy) }
    it { should have_many(:feats).through(:character_feats) }
    it { should have_many(:character_notes).dependent(:destroy) }
    it { should have_many(:weapons).dependent(:destroy) }
    it { should have_many(:quest_logs).dependent(:destroy) }
    it { should have_many(:solo_sessions).dependent(:destroy) }
    it { should have_many(:character_relationships).dependent(:destroy) }
    it { should have_many(:related_characters).through(:character_relationships) }
    it { should have_many(:inverse_relationships) }
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

    describe '.search_name' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.search_name).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.user_id_min' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.user_id_min).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.user_id_max' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.user_id_max).to be_an(ActiveRecord::Relation)
      end
    end

  end

end