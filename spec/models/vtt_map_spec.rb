# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VttMap, type: :model do
  describe 'associations' do
    it { should belong_to(:vtt_session) }
  end

  describe 'validations' do
    it { should validate_presence_of(:background_url) }
    it { should validate_numericality_of(:width) }
  end

end