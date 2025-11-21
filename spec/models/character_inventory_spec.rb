# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterInventory, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
  end

  describe 'validations' do
    it { should validate_presence_of(:character_id) }
    it { should validate_numericality_of(:carry_capacity) }
    it { should validate_numericality_of(:current_weight) }
  end

end