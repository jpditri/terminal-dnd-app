# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterSpellManager, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
  end

  describe 'validations' do
    it { should validate_presence_of(:character_id) }
  end

end