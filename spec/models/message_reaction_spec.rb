# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageReaction, type: :model do
  describe 'associations' do
    it { should belong_to(:chat_message) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:emoji) }
    it { should validate_uniqueness_of(:user_id) }
  end

end