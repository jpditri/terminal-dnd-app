# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterCombatTracker, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
  end

  describe 'validations' do
    it { should validate_presence_of(:character_id) }
    it { should validate_numericality_of(:exhaustion_level) }
    it { should validate_numericality_of(:temp_hp) }
  end

end