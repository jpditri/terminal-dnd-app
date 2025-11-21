# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserThemePreference, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
  end

  describe 'scopes' do
    describe '.dark_mode' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.dark_mode).to be_an(ActiveRecord::Relation)
      end
    end

    describe '.high_contrast' do
      it 'returns expected records' do
        # TODO: Add scope test
        expect(described_class.high_contrast).to be_an(ActiveRecord::Relation)
      end
    end

  end

end