# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiDmAssistant, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign) }
    it { should have_many(:ai_dm_suggestions).dependent(:destroy) }
    it { should have_many(:ai_dm_contexts).dependent(:destroy) }
    it { should have_many(:ai_dm_overrides).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:campaign_id) }
  end

end